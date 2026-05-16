import AVFoundation
import SwiftUI
import CoreML
import Vision
internal import Combine

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var isPermissionGranted = false
    private var photoOutput = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage? = nil
    @Published var detectedCondition: String? = nil
    
    // ML Model Scores
    @Published var currentAcneScore: Double = 0
    @Published var currentRednessScore: Double = 0
    @Published var currentPsoriasisScore: Double = 0
    
    @Published var wrinkleScore: Double = 0
    @Published var eyebagScore: Double = 0
    @Published var analysisRecord: AnalysisRecord? = nil
    @Published var isAnalyzing: Bool = false
    
    private let engine = ScoringEngine()
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isPermissionGranted = true
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isPermissionGranted = granted
                    if granted {
                        self.setupSession()
                    }
                }
            }
        default:
            self.isPermissionGranted = false
        }
    }
    
    func setupSession() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else
        {
            print("no front camera")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                if device.isSubjectAreaChangeMonitoringEnabled {
                    device.isSubjectAreaChangeMonitoringEnabled = true
                }
                device.unlockForConfiguration()
            }
            
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print("camera setup error: \(error.localizedDescription)")
        }
    }
    
    func capturePhoto() {
        // 1. Clear previous data and signal START immediately to trigger UI animation
        DispatchQueue.main.async {
            self.capturedImage = nil
            self.analysisRecord = nil
            self.isAnalyzing = true 
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: data) else { 
            DispatchQueue.main.async { self.isAnalyzing = false }
            return 
        }

        // Show the captured frame immediately in the "freeze" state with correct orientation
        DispatchQueue.main.async {
            self.capturedImage = originalImage.fixedOrientation()
        }

        // 2. Process on background queue and FORCE a 3-second delay for the animation
        Task {
            let startTime = Date()
            
            // Correct orientation for analysis
            guard let normalizedImage = originalImage.fixedOrientation() else {
                await MainActor.run { self.isAnalyzing = false }
                return
            }
            
            let croppedImage = await withCheckedContinuation { continuation in
                detectFaceAndCrop(normalizedImage) { cropped in
                    continuation.resume(returning: cropped)
                }
            }
            
            let imageToAnalyze = croppedImage ?? normalizedImage
            
            // Perform analysis
            let group = DispatchGroup()
            group.enter()
            self.analyzeWithCoreML(imageToAnalyze, group: group)
            group.enter()
            self.analyzeWithVision(imageToAnalyze, group: group)
            
            await withCheckedContinuation { continuation in
                group.notify(queue: .global()) {
                    continuation.resume()
                }
            }
            
            // Wait to ensure the 3s scanning animation completes
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 3.0 {
                try? await Task.sleep(nanoseconds: UInt64((3.0 - elapsed) * 1_000_000_000))
            }
            
            await MainActor.run {
                self.capturedImage = imageToAnalyze
                self.buildRecord()
            }
        }
    }

    private func detectFaceAndCrop(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                completion(nil)
                return
            }
            
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            let box = face.boundingBox
            
            let rect = CGRect(
                x: box.origin.x * width,
                y: (1 - box.origin.y - box.height) * height,
                width: box.width * width,
                height: box.height * height
            )
            
            let padding = rect.width * 0.4
            let paddedRect = rect.insetBy(dx: -padding, dy: -padding)
            
            if let faceImage = cgImage.cropping(to: paddedRect) {
                // Return upright image (already normalized)
                completion(UIImage(cgImage: faceImage))
            } else {
                completion(nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        try? handler.perform([request])
    }
    
    func analyzeWithCoreML(_ image: UIImage, group: DispatchGroup) {
        let inputSize = 384
        let mean: [Float] = [0.5942, 0.4433, 0.3871]
        let std: [Float]  = [0.2427, 0.2027, 0.1930]

        guard let resized = image.resizedForML(to: inputSize),
              let cgImage = resized.cgImage else {
            group.leave()
            return
        }

        var pixels = [UInt8](repeating: 0, count: inputSize * inputSize * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &pixels, width: inputSize, height: inputSize,
                                  bitsPerComponent: 8, bytesPerRow: inputSize * 4,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            group.leave()
            return
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: inputSize, height: inputSize))

        guard let tensor = try? MLMultiArray(shape: [1, 3, inputSize, inputSize] as [NSNumber], dataType: .float32) else {
            group.leave()
            return
        }

        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(tensor.dataPointer))
        let hw = inputSize * inputSize
        for c in 0..<3 {
            for i in 0..<hw {
                let raw = Float(pixels[i * 4 + c]) / 255.0
                ptr[c * hw + i] = (raw - mean[c]) / std[c]
            }
        }

        let model: skin_disease
        do { model = try skin_disease(configuration: MLModelConfiguration()) }
        catch { 
            NSLog("ML model could not be loaded: %@", error.localizedDescription)
            group.leave()
            return 
        }

        let output: skin_diseaseOutput
        do { output = try model.prediction(image: tensor) }
        catch { 
            NSLog("ML prediction error: %@", error.localizedDescription)
            group.leave()
            return 
        }

        let out = output.var_763
        func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) * 100 }
        let acneLogit      = Double(truncating: out[[0, 0] as [NSNumber]])
        let rednessLogit    = Double(truncating: out[[0, 1] as [NSNumber]])
        let psoriasisLogit = Double(truncating: out[[0, 2] as [NSNumber]])

        let acne      = sigmoid(acneLogit)
        let redness    = sigmoid(rednessLogit)
        let psoriasis = sigmoid(psoriasisLogit)

        let condition = ["Acne": acne, "Redness": redness, "Psoriasis": psoriasis]
        let top = condition.max(by: { $0.value < $1.value })

        DispatchQueue.main.async {
            self.currentAcneScore      = acne
            self.currentRednessScore  = redness
            self.currentPsoriasisScore = psoriasis
            self.detectedCondition = (top?.value ?? 0) > 40 ? top?.key : "Healthy"
            group.leave()
        }
    }
    
    func analyzeWithVision(_ image: UIImage, group: DispatchGroup) {
        guard let ciImage = CIImage(image: image) else { 
            group.leave()
            return
        }
        
        let request = VNDetectFaceLandmarksRequest { request, error in
            defer { group.leave() }
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else { return }
            self.calculateWrinkleScore(ciImage: ciImage, face: face)
            self.calculateEyebagScore(ciImage: ciImage, face: face)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            NSLog("Vision request error: %@", error.localizedDescription)
            group.leave()
        }
    }

    func calculateWrinkleScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let foreheadRect = CGRect(
            x: face.boundingBox.minX * imageSize.width,
            y: (face.boundingBox.maxY - 0.15) * imageSize.height,
            width: face.boundingBox.width * imageSize.width,
            height: 0.1 * imageSize.height
        )
        
        let cropped = ciImage.cropped(to: foreheadRect)
        let edges = cropped.applyingFilter("CIEdges", parameters: ["inputIntensity": 5.0])
        
        guard let cgImage = CIContext().createCGImage(edges, from: edges.extent) else { return }
        let brightness = cgImage.averageBrightness
        
        DispatchQueue.main.async {
            self.wrinkleScore = min(brightness * 300, 100)
        }
    }
    
    func calculateEyebagScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let eyeY = (face.boundingBox.minY + face.boundingBox.height * 0.55) * imageSize.height
        let eyeAreaRect = CGRect(
            x: face.boundingBox.minX * imageSize.width,
            y: eyeY,
            width: face.boundingBox.width * imageSize.width,
            height: face.boundingBox.height * 0.15 * imageSize.height
        )
        
        let cropped = ciImage.cropped(to: eyeAreaRect)
        guard let cgImage = CIContext().createCGImage(cropped, from: cropped.extent) else { return }
        let darkness = 1.0 - cgImage.averageBrightness
    
        DispatchQueue.main.async {
            self.eyebagScore = min(darkness * 150, 100)
        }
    }
    
    func buildRecord() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        let skinType = profile?.skinType?.lowercased() ?? "normal"
        let skinScores = engine.calculateScore(acne: currentAcneScore / 100, redness: currentRednessScore / 100, psoriasis: currentPsoriasisScore / 100, benLezyon: 0.0, healthy: 0.0, skinType: skinType)

        let imageData = capturedImage?.jpegData(compressionQuality: 0.8)
        
        let record = LocalPersistenceManager.shared.saveAnalysisRecord(
            condition: detectedCondition ?? "Healthy",
            confidence: 0,
            wrinkleScore: wrinkleScore,
            eyebagScore: eyebagScore,
            date: Date(),
            drynessScore: skinScores.drynessScore,
            inflammationScore: skinScores.inflammationScore,
            oilinessScore: skinScores.oilinessScore,
            overallScore: skinScores.overallScore,
            userFeedback: false,
            acneScore: currentAcneScore,
            eczemaScore: currentRednessScore,
            psoriasisScore: currentPsoriasisScore,
            imageData: imageData
        )

        SubscriptionManager.shared.recordScan()
        self.isAnalyzing = false
        self.analysisRecord = record
    }
    
    func resetScanner() {
        DispatchQueue.main.async {
            self.capturedImage = nil
            self.analysisRecord = nil
            self.isAnalyzing = false
        }
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
}

extension UIImage {
    func resizedForML(to size: Int) -> UIImage? {
        let s = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(s, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: s))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

extension CGImage {
    var averageBrightness: Double {
        guard let data = dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return 0 }
        let length = CFDataGetLength(data)
        var total: Double = 0
        var count = 0
        for i in stride(from: 0, to: length, by: 4) {
            let r = Double(bytes[i])
            let g = Double(bytes[i+1])
            let b = Double(bytes[i+2])
            total += (r + g + b) / 3.0
            count += 1
        }
        return count > 0 ? (total / Double(count)) / 255.0 : 0
    }
}

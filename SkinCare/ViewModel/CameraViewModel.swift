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
    @Published var currentEczemaScore: Double = 0
    @Published var currentPsoriasisScore: Double = 0
    
    @Published var wrinkleScore: Double = 0
    @Published var eyebagScore: Double = 0
    @Published var analysisRecord: AnalysisRecord? = nil
    @Published var isAnalyzing: Bool = false
    
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
        // camera setup logic
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
            
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print("camera setup error: \(error.localizedDescription)")
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
        }

        detectFaceAndCrop(originalImage) { croppedImage in
            let imageToAnalyze = croppedImage ?? originalImage
            
            DispatchQueue.main.async {
                self.capturedImage = imageToAnalyze
            }
            
            let group = DispatchGroup()
            group.enter()
            self.analyzeWithCoreML(imageToAnalyze, group: group)
            group.enter()
            self.analyzeWithVision(imageToAnalyze, group: group)

            group.notify(queue: .main) {
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
            
            // Vision coordinates are normalized (0-1) and origin is bottom-left
            let box = face.boundingBox
            let rect = CGRect(
                x: box.origin.x * width,
                y: (1 - box.origin.y - box.height) * height,
                width: box.width * width,
                height: box.height * height
            )
            
            // Add padding (20%) to capture more skin area around the face
            let padding = rect.width * 0.2
            let paddedRect = rect.insetBy(dx: -padding, dy: -padding)
            
            if let faceImage = cgImage.cropping(to: paddedRect) {
                completion(UIImage(cgImage: faceImage, scale: image.scale, orientation: image.imageOrientation))
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
        // class order from training: Acne=0, Eczema=1, Psoriasis=2, Ben_Lezyon=3, Healthy=4 (ben_lezyon and healthy are cancelled)

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
        catch { NSLog("ML model yüklenemedi: %@", error.localizedDescription); group.leave(); return }

        let output: skin_diseaseOutput
        do { output = try model.prediction(image: tensor) }
        catch { NSLog("ML prediction hata: %@", error.localizedDescription); group.leave(); return }

        let out = output.var_763
        func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) * 100 }
        let acneLogit      = Double(truncating: out[[0, 0] as [NSNumber]])
        let eczemaLogit    = Double(truncating: out[[0, 1] as [NSNumber]])
        let psoriasisLogit = Double(truncating: out[[0, 2] as [NSNumber]])
        NSLog("ML logits → acne:%.3f eczema:%.3f psoriasis:%.3f", acneLogit, eczemaLogit, psoriasisLogit)

        let acne      = sigmoid(acneLogit)
        let eczema    = sigmoid(eczemaLogit)
        let psoriasis = sigmoid(psoriasisLogit)

        let condition = ["Acne": acne, "Eczema": eczema, "Psoriasis": psoriasis]
            .max(by: { $0.value < $1.value })?.key ?? "Healthy"

        DispatchQueue.main.async {
            self.currentAcneScore    = acne
            self.currentEczemaScore  = eczema
            self.currentPsoriasisScore = psoriasis
            self.detectedCondition   = condition
            group.leave()
        }
    }
    
    func analyzeWithVision(_ image: UIImage, group: DispatchGroup) {
        guard let ciImage = CIImage(image: image) else { 
            group.leave()
            return
        }
        
        let request = VNDetectFaceLandmarksRequest { request, error in
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else { return }
                self.calculateWrinkleScore(ciImage: ciImage, face: face)
                self.calculateEyebagScore(ciImage: ciImage, face: face)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try? handler.perform([request])
        group.leave()
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
        // Vision koordinatı bottom-left origin. Göz altı = yüz bounding box'ın alt yarısının üst kısmı (~%55-70)
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
        
        let engine = ScoringEngine()
        let skinScores = engine.calculateScore(acne: currentAcneScore / 100, eczema: currentEczemaScore / 100, psoriasis: currentPsoriasisScore / 100, benLezyon: 0.0, healthy: 0.0, skinType: skinType)
        
        let record = LocalPersistenceManager.shared.saveAnalysisRecord(
            condition: detectedCondition ?? "Healthy",
            confidence: 1.0,
            wrinkleScore: wrinkleScore,
            eyebagScore: eyebagScore,
            date: Date(),
            drynessScore: skinScores.drynessScore,
            inflammationScore: skinScores.inflammationScore,
            oilinessScore: skinScores.oilinessScore,
            overallScore: skinScores.overallScore,
            userFeedback: false,
            acneScore: currentAcneScore,
            eczemaScore: currentEczemaScore,
            psoriasisScore: currentPsoriasisScore,
            imageData: capturedImage?.jpegData(compressionQuality: 0.8)
        )
        SubscriptionManager.shared.recordScan()
        self.isAnalyzing = false
        self.analysisRecord = record
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


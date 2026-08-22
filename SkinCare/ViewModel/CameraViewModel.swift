import AVFoundation
import SwiftUI
import CoreML
import Vision
internal import Combine

enum CameraPermissionStatus {
    case notDetermined
    case authorized
    case denied
}

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var permissionStatus: CameraPermissionStatus = .notDetermined
    @Published var isPermissionGranted = false
    private var photoOutput = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage? = nil
    @Published var detectedCondition: String? = nil

    @Published var currentAcneScore: Double = 0
    @Published var currentRednessScore: Double = 0

    @Published var wrinkleScore: Double = 0
    @Published var eyebagScore: Double = 0
    @Published var pigmentationScore: Double = 0
    @Published var hydrationScore: Double = 0
    @Published var analysisRecord: AnalysisRecord? = nil
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String? = nil

    private let engine = ScoringEngine()

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionStatus = .authorized
            self.isPermissionGranted = true
            self.setupSession()
        case .notDetermined:
            self.permissionStatus = .notDetermined
            self.isPermissionGranted = false
        default:
            self.permissionStatus = .denied
            self.isPermissionGranted = false
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                self.permissionStatus = granted ? .authorized : .denied
                if granted {
                    self.setupSession()
                }
            }
        }
    }

    func setupSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("no front camera")
            return
        }

        session.beginConfiguration()
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
        } catch {
            print("camera setup error: \(error.localizedDescription)")
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func capturePhoto() {
        DispatchQueue.main.async {
            self.capturedImage = nil
            self.analysisRecord = nil
            self.detectedCondition = nil
            self.currentAcneScore = 0
            self.currentRednessScore = 0
            self.wrinkleScore = 0
            self.eyebagScore = 0
            self.pigmentationScore = 0
            self.hydrationScore = 0
            self.isAnalyzing = true
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              var originalImage = UIImage(data: data) else {
            DispatchQueue.main.async {
                self.isAnalyzing = false
                self.errorMessage = NSLocalizedString("analysis_error_photo", comment: "")
            }
            return
        }

        if let deviceInput = session.inputs.first as? AVCaptureDeviceInput,
           deviceInput.device.position == .front {
            if let cgImage = originalImage.cgImage {
                originalImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: .leftMirrored)
            }
        }

        DispatchQueue.main.async {
            self.capturedImage = originalImage.fixedOrientation()
        }

        Task {
            let startTime = Date()

            guard let normalizedImage = originalImage.fixedOrientation() else {
                await MainActor.run {
                    self.isAnalyzing = false
                    self.errorMessage = NSLocalizedString("analysis_error_photo", comment: "")
                }
                return
            }

            let (croppedImage, _) = await withCheckedContinuation { continuation in
                detectFaceAndCrop(normalizedImage) { cropped, faceNormRect in
                    continuation.resume(returning: (cropped, faceNormRect))
                }
            }

            let imageToAnalyze = croppedImage ?? normalizedImage

            self.analyzeWithCoreML(imageToAnalyze)
            await self.analyzeSecondaryConditions(imageToAnalyze)

            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 3.0 {
                try? await Task.sleep(nanoseconds: UInt64((3.0 - elapsed) * 1_000_000_000))
            }

            await MainActor.run {
                self.capturedImage = normalizedImage
                self.buildRecord()
            }
        }
    }

    private func detectFaceAndCrop(_ image: UIImage, completion: @escaping (UIImage?, CGRect) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil, .zero)
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                completion(nil, .zero)
                return
            }

            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            let box = face.boundingBox

            // Normalized face rect (0-1, UIKit coords: origin top-left)
            let normalizedFaceRect = CGRect(
                x: box.origin.x,
                y: 1 - box.origin.y - box.height,
                width: box.width,
                height: box.height
            )

            let rect = CGRect(
                x: box.origin.x * width,
                y: (1 - box.origin.y - box.height) * height,
                width: box.width * width,
                height: box.height * height
            )

            let imageBounds = CGRect(x: 0, y: 0, width: width, height: height)
            let faceRect = rect.intersection(imageBounds)

            if !faceRect.isEmpty, let faceImage = cgImage.cropping(to: faceRect) {
                completion(UIImage(cgImage: faceImage), normalizedFaceRect)
            } else {
                completion(nil, .zero)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        try? handler.perform([request])
    }

    func analyzeWithCoreML(_ image: UIImage) {
        let inputSize = 384
        let mean: [Float] = [0.5942, 0.4433, 0.3871]
        let std: [Float]  = [0.2427, 0.2027, 0.1930]

        guard let resized = image.resizedForML(to: inputSize),
              let cgImage = resized.cgImage else {
            return
        }

        var pixels = [UInt8](repeating: 0, count: inputSize * inputSize * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &pixels, width: inputSize, height: inputSize,
                                  bitsPerComponent: 8, bytesPerRow: inputSize * 4,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            return
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: inputSize, height: inputSize))

        guard let tensor = try? MLMultiArray(shape: [1, 3, inputSize, inputSize] as [NSNumber], dataType: .float32) else {
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

        let mlModel: MLModel
        do {
            guard let modelURL = Bundle.main.url(forResource: "skin_disease", withExtension: "mlmodelc")
                    ?? Bundle.main.url(forResource: "skin_disease", withExtension: "mlpackage") else {
                NSLog("ML model file not found in bundle")
                DispatchQueue.main.async {
                    self.errorMessage = NSLocalizedString("analysis_error_model", comment: "")
                }
                return
            }
            mlModel = try MLModel(contentsOf: modelURL, configuration: MLModelConfiguration())
        } catch {
            NSLog("ML model could not be loaded: %@", error.localizedDescription)
            DispatchQueue.main.async {
                self.errorMessage = NSLocalizedString("analysis_error_model", comment: "")
            }
            return
        }

        let provider = try? MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(multiArray: tensor)])
        guard let provider = provider else {
            return
        }

        let output: MLFeatureProvider
        do { output = try mlModel.prediction(from: provider) }
        catch {
            NSLog("ML prediction error: %@", error.localizedDescription)
            DispatchQueue.main.async {
                self.errorMessage = NSLocalizedString("analysis_error_model", comment: "")
            }
            return
        }

        let outputNames = output.featureNames
        let scores = output.featureValue(for: "scores")?.multiArrayValue
            ?? outputNames.compactMap { output.featureValue(for: $0)?.multiArrayValue }.first

        guard let scores else {
            NSLog("ML multi-array output not found")
            return
        }

        func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) * 100 }
        
        func processedScore(_ logit: Double) -> Double {
            let temperature = 1.8
            let score = sigmoid(logit / temperature)
            return min(max(score, 1), 99)
        }

        let acneLogit    = Double(truncating: scores[[0, 0] as [NSNumber]])
        let eczemaLogit = Double(truncating: scores[[0, 1] as [NSNumber]])

        let acne     = processedScore(acneLogit)
        let eczema  = processedScore(eczemaLogit)

        let condition = [
            "Acne": acne,
            "Redness": eczema
        ]
        let top = condition.max(by: { $0.value < $1.value })

        DispatchQueue.main.async {
            self.currentAcneScore     = acne
            self.currentRednessScore  = eczema
            // processedScore centers at 50 for a zero logit, so 60 demands
            // genuinely positive evidence before naming a condition.
            self.detectedCondition = (top?.value ?? 0) >= 60 ? top?.key : "Healthy"
        }
    }

    func analyzeSecondaryConditions(_ image: UIImage) async {
        do {
            let result = try await GeminiVLMService.shared.analyzeFace(image)
            await MainActor.run {
                self.wrinkleScore = result.wrinkles.score
                self.eyebagScore = result.eyebags.score
                self.pigmentationScore = result.pigmentation.score
                self.hydrationScore = result.hydration.score
            }
        } catch {
            NSLog("VLM error: %@", error.localizedDescription)
            await legacySecondaryConditions(image)
        }
    }

    private func legacySecondaryConditions(_ image: UIImage) async {
        await withCheckedContinuation { continuation in
            let group = DispatchGroup()
            group.enter()
            self.analyzeWithVision(image, group: group)
            group.notify(queue: .global()) {
                continuation.resume()
            }
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
            self.calculatePigmentationScore(ciImage: ciImage, face: face)
            self.calculateHydrationScore(ciImage: ciImage, face: face)
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            NSLog("Vision request error: %@", error.localizedDescription)
            group.leave()
        }
    }

    // MARK: - Wrinkle Detection (Gabor-like horizontal edge analysis)
    func calculateWrinkleScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let box = face.boundingBox
        let ctx = CIContext()

        // Forehead: wider region so we have enough texture to measure on real devices
        let foreheadRect = CGRect(
            x: (box.minX + box.width * 0.10) * imageSize.width,
            y: (box.minY + box.height * 0.78) * imageSize.height,
            width: box.width * 0.80 * imageSize.width,
            height: box.height * 0.18 * imageSize.height
        ).intersection(imageSize)

        // Crow's feet left: outer left of face at eye level
        let crowsFeetLeftRect = CGRect(
            x: (box.minX - box.width * 0.02) * imageSize.width,
            y: (box.minY + box.height * 0.40) * imageSize.height,
            width: box.width * 0.26 * imageSize.width,
            height: box.height * 0.22 * imageSize.height
        ).intersection(imageSize)

        // Crow's feet right: outer right of face at eye level
        let crowsFeetRightRect = CGRect(
            x: (box.minX + box.width * 0.76) * imageSize.width,
            y: (box.minY + box.height * 0.40) * imageSize.height,
            width: box.width * 0.26 * imageSize.width,
            height: box.height * 0.22 * imageSize.height
        ).intersection(imageSize)

        func wrinkleDensity(in rect: CGRect) -> Double {
            guard !rect.isEmpty else { return 0 }
            let cropped = ciImage.cropped(to: rect)
            let gray = cropped.applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.3
            ])
            guard let cgImg = ctx.createCGImage(gray, from: gray.extent),
                  let data = cgImg.dataProvider?.data,
                  let bytes = CFDataGetBytePtr(data) else { return 0 }

            let width = cgImg.width
            let height = cgImg.height
            let byteCount = CFDataGetLength(data)
            guard width > 1, height > 1, byteCount >= width * height * 4 else { return 0 }

            var luminances = [Double]()
            luminances.reserveCapacity(width * height)
            for i in stride(from: 0, to: width * height * 4, by: 4) {
                let r = Double(bytes[i])
                let g = Double(bytes[i + 1])
                let b = Double(bytes[i + 2])
                luminances.append(((r + g + b) / 3.0) / 255.0)
            }

            guard !luminances.isEmpty else { return 0 }

            let mean = luminances.reduce(0, +) / Double(luminances.count)
            let variance = luminances.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(luminances.count)
            let stdDev = sqrt(variance)

            var horizontalContrast: Double = 0
            var horizontalSamples = 0
            if width > 1 {
                for row in 0..<height {
                    let rowStart = row * width
                    if rowStart + width <= luminances.count {
                        for col in 1..<width {
                            let current = luminances[rowStart + col]
                            let previous = luminances[rowStart + col - 1]
                            horizontalContrast += abs(current - previous)
                            horizontalSamples += 1
                        }
                    }
                }
            }

            let horizontalMean = horizontalSamples > 0 ? horizontalContrast / Double(horizontalSamples) : 0
            return min(1.0, stdDev * 1.8 + horizontalMean * 3.2)
        }

        let foreheadScore = wrinkleDensity(in: foreheadRect)
        let crowsLeftScore = wrinkleDensity(in: crowsFeetLeftRect)
        let crowsRightScore = wrinkleDensity(in: crowsFeetRightRect)

        let combined = foreheadScore * 0.50 + crowsLeftScore * 0.25 + crowsRightScore * 0.25
        let normalized = min(1.0, max(0, combined))
        let curved = pow(normalized, 1.45)
        let finalScore = min(max(curved * 85, 4), 85)

        NSLog("[WRINKLE] face box: %.2f,%.2f %.2fx%.2f | forehead: %.3f crowsL: %.3f crowsR: %.3f combined: %.3f → score: %.1f",
              box.minX, box.minY, box.width, box.height,
              foreheadScore, crowsLeftScore, crowsRightScore, combined, finalScore)

        DispatchQueue.main.async {
            self.wrinkleScore = finalScore
        }
    }

    // MARK: - Eyebag Detection (LAB color difference + texture)
    func calculateEyebagScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let box = face.boundingBox
        let ctx = CIContext()

        // Under-eye: slightly wider band below the eye line to capture shadows and puffiness
        let underEyeY = (box.minY + box.height * 0.47) * imageSize.height
        let leftEyeRect = CGRect(
            x: (box.minX + box.width * 0.08) * imageSize.width,
            y: underEyeY,
            width: box.width * 0.32 * imageSize.width,
            height: box.height * 0.12 * imageSize.height
        ).intersection(imageSize)

        let rightEyeRect = CGRect(
            x: (box.minX + box.width * 0.60) * imageSize.width,
            y: underEyeY,
            width: box.width * 0.32 * imageSize.width,
            height: box.height * 0.12 * imageSize.height
        ).intersection(imageSize)

        // Cheek reference: a little lower and broader for a more stable comparison
        let cheekY = (box.minY + box.height * 0.34) * imageSize.height
        let cheekRect = CGRect(
            x: (box.minX + box.width * 0.16) * imageSize.width,
            y: cheekY,
            width: box.width * 0.68 * imageSize.width,
            height: box.height * 0.10 * imageSize.height
        ).intersection(imageSize)

        func regionBrightness(_ rect: CGRect) -> (luminance: Double, texture: Double) {
            guard !rect.isEmpty else { return (0.5, 0) }
            let cropped = ciImage.cropped(to: rect)
            guard let cgImg = ctx.createCGImage(cropped, from: cropped.extent) else { return (0.5, 0) }
            let lum = cgImg.averageBrightness

            let edges = cropped.applyingFilter("CIEdges", parameters: ["inputIntensity": 3.0])
            guard let edgeCg = ctx.createCGImage(edges, from: edges.extent) else { return (lum, 0) }
            let tex = edgeCg.averageBrightness

            return (lum, tex)
        }

        let leftEye = regionBrightness(leftEyeRect)
        let rightEye = regionBrightness(rightEyeRect)
        let cheek = regionBrightness(cheekRect)

        let avgEyeLum = (leftEye.luminance + rightEye.luminance) / 2.0
        let avgEyeTex = (leftEye.texture + rightEye.texture) / 2.0

        // Darkness relative to cheek (skin-tone independent)
        let darknessDiff = max(0, cheek.luminance - avgEyeLum)
        let darknessScore = sqrt(darknessDiff) * 220

        // Texture under eyes indicates puffiness/bags
        let textureScore = sqrt(avgEyeTex) * 140

        let finalScore = min(darknessScore * 0.7 + textureScore * 0.3, 100)

        NSLog("[EYEBAG] eyeLum: %.3f cheekLum: %.3f diff: %.3f eyeTex: %.3f → darkness: %.1f texture: %.1f final: %.1f",
              avgEyeLum, cheek.luminance, darknessDiff, avgEyeTex, darknessScore, textureScore, finalScore)

        DispatchQueue.main.async {
            self.eyebagScore = finalScore
        }
    }

    // MARK: - Pigmentation Detection (color uniformity in LAB-approximated space)
    func calculatePigmentationScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let box = face.boundingBox
        let ctx = CIContext()

        let faceRect = CGRect(
            x: (box.minX + box.width * 0.10) * imageSize.width,
            y: (box.minY + box.height * 0.20) * imageSize.height,
            width: box.width * 0.80 * imageSize.width,
            height: box.height * 0.60 * imageSize.height
        ).intersection(imageSize)

        guard !faceRect.isEmpty else {
            DispatchQueue.main.async { self.pigmentationScore = 0 }
            return
        }

        let cropped = ciImage.cropped(to: faceRect)
        guard let cgImg = ctx.createCGImage(cropped, from: cropped.extent),
              let data = cgImg.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            DispatchQueue.main.async { self.pigmentationScore = 0 }
            return
        }

        let length = CFDataGetLength(data)
        var luminances: [Double] = []
        luminances.reserveCapacity(length / 4)

        for i in stride(from: 0, to: length, by: 4) {
            let r = Double(bytes[i]) / 255.0
            let g = Double(bytes[i + 1]) / 255.0
            let b = Double(bytes[i + 2]) / 255.0
            // Perceived luminance (approximates L* channel)
            let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
            luminances.append(lum)
        }

        guard !luminances.isEmpty else {
            DispatchQueue.main.async { self.pigmentationScore = 0 }
            return
        }

        let mean = luminances.reduce(0, +) / Double(luminances.count)
        let variance = luminances.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(luminances.count)
        let stdDev = sqrt(variance)

        let finalScore = min(stdDev * 500, 100)

        NSLog("[PIGMENT] pixels: %d meanLum: %.3f stdDev: %.4f → score: %.1f",
              luminances.count, mean, stdDev, finalScore)

        DispatchQueue.main.async {
            self.pigmentationScore = finalScore
        }
    }

    // MARK: - Hydration Detection (specular highlights + texture smoothness)
    func calculateHydrationScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let box = face.boundingBox
        let ctx = CIContext()

        let skinRect = CGRect(
            x: (box.minX + box.width * 0.15) * imageSize.width,
            y: (box.minY + box.height * 0.25) * imageSize.height,
            width: box.width * 0.70 * imageSize.width,
            height: box.height * 0.50 * imageSize.height
        ).intersection(imageSize)

        guard !skinRect.isEmpty else {
            DispatchQueue.main.async { self.hydrationScore = 50 }
            return
        }

        let cropped = ciImage.cropped(to: skinRect)
        guard let cgImg = ctx.createCGImage(cropped, from: cropped.extent),
              let data = cgImg.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            DispatchQueue.main.async { self.hydrationScore = 50 }
            return
        }

        let length = CFDataGetLength(data)
        var totalBrightness: Double = 0
        var highlightPixels = 0
        var pixelCount = 0

        for i in stride(from: 0, to: length, by: 4) {
            let r = Double(bytes[i]) / 255.0
            let g = Double(bytes[i + 1]) / 255.0
            let b = Double(bytes[i + 2]) / 255.0
            let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
            totalBrightness += lum
            // Specular highlights indicate moisture on skin surface
            if lum > 0.85 { highlightPixels += 1 }
            pixelCount += 1
        }

        guard pixelCount > 0 else {
            DispatchQueue.main.async { self.hydrationScore = 50 }
            return
        }

        let highlightRatio = Double(highlightPixels) / Double(pixelCount)

        // Texture smoothness: fewer edges = smoother = more hydrated
        let edges = cropped.applyingFilter("CIEdges", parameters: ["inputIntensity": 2.0])
        let edgeCg = ctx.createCGImage(edges, from: edges.extent)
        let edgeIntensity = edgeCg?.averageBrightness ?? 0.5

        // Smoothness: inverse of edge intensity
        let smoothness = max(0, 1.0 - edgeIntensity * 3.0)

        // Balanced hydration: some highlight (not too matte, not too oily) + smooth texture
        let highlightScore: Double
        if highlightRatio < 0.02 {
            highlightScore = highlightRatio * 25.0 // Very matte = dry
        } else if highlightRatio < 0.15 {
            highlightScore = 0.5 + highlightRatio * 2.0 // Healthy range
        } else {
            highlightScore = max(0.3, 0.8 - highlightRatio) // Too shiny = oily, not hydrated
        }

        let finalScore = min((highlightScore * 0.40 + smoothness * 0.60) * 120, 100)

        NSLog("[HYDRATION] highlightRatio: %.4f edgeIntensity: %.3f smoothness: %.3f highlightScore: %.3f → score: %.1f",
              highlightRatio, edgeIntensity, smoothness, highlightScore, finalScore)

        DispatchQueue.main.async {
            self.hydrationScore = finalScore
        }
    }

    func buildRecord() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        let skinType = profile?.skinType?.lowercased() ?? "normal"
        let skinScores = engine.calculateScore(
            acne: currentAcneScore / 100,
            redness: currentRednessScore / 100,
            pigmentation: pigmentationScore / 100,
            hydration: hydrationScore / 100,
            wrinkles: wrinkleScore / 100,
            eyebags: eyebagScore / 100,
            skinType: skinType
        )

        let imageData = capturedImage?.jpegData(compressionQuality: 0.5)

        let record = LocalPersistenceManager.shared.saveAnalysisRecord(
            condition: detectedCondition ?? "Healthy",
            confidence: max(currentAcneScore, currentRednessScore) / 100.0,
            wrinkleScore: wrinkleScore,
            eyebagScore: eyebagScore,
            pigmentationScore: pigmentationScore,
            hydrationScore: hydrationScore,
            date: Date(),
            drynessScore: skinScores.drynessScore,
            inflammationScore: skinScores.inflammationScore,
            oilinessScore: skinScores.oilinessScore,
            overallScore: skinScores.overallScore,
            userFeedback: false,
            acneScore: currentAcneScore,
            eczemaScore: currentRednessScore,
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
            self.detectedCondition = nil
            self.errorMessage = nil
            self.currentAcneScore = 0
            self.currentRednessScore = 0
            self.wrinkleScore = 0
            self.eyebagScore = 0
            self.pigmentationScore = 0
            self.hydrationScore = 0
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

    var edgeIntensity: Double {
        guard let data = dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return 0 }
        let length = CFDataGetLength(data)
        var aboveThreshold = 0
        var count = 0
        for i in stride(from: 0, to: length, by: 4) {
            let r = Double(bytes[i]) / 255.0
            let g = Double(bytes[i+1]) / 255.0
            let b = Double(bytes[i+2]) / 255.0
            let val = (r + g + b) / 3.0
            if val > 0.08 { aboveThreshold += 1 }
            count += 1
        }
        return count > 0 ? Double(aboveThreshold) / Double(count) : 0
    }
}

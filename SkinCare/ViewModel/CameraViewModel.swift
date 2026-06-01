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
    var heatmaps: [String: [[Float]]] = [:]
    var faceRect: CGRect = .zero

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
              var originalImage = UIImage(data: data) else {
            DispatchQueue.main.async { self.isAnalyzing = false }
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
                await MainActor.run { self.isAnalyzing = false }
                return
            }

            let (croppedImage, _) = await withCheckedContinuation { continuation in
                detectFaceAndCrop(normalizedImage) { cropped, faceNormRect in
                    continuation.resume(returning: (cropped, faceNormRect))
                }
            }

            let imageToAnalyze = croppedImage ?? normalizedImage

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

            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 3.0 {
                try? await Task.sleep(nanoseconds: UInt64((3.0 - elapsed) * 1_000_000_000))
            }

            await MainActor.run {
                self.capturedImage = imageToAnalyze
                self.faceRect = .zero
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

            let paddingW = rect.width * 0.08
            let paddingH = rect.height * 0.15
            let expanded = rect.insetBy(dx: -paddingW, dy: -paddingH)
            let imageBounds = CGRect(x: 0, y: 0, width: width, height: height)
            let paddedRect = expanded.intersection(imageBounds)

            if !paddedRect.isEmpty, let faceImage = cgImage.cropping(to: paddedRect) {
                completion(UIImage(cgImage: faceImage), normalizedFaceRect)
            } else {
                completion(nil, .zero)
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

        let mlModel: MLModel
        do {
            guard let modelURL = Bundle.main.url(forResource: "skin_disease", withExtension: "mlmodelc")
                    ?? Bundle.main.url(forResource: "skin_disease", withExtension: "mlpackage") else {
                NSLog("ML model file not found in bundle")
                group.leave()
                return
            }
            mlModel = try MLModel(contentsOf: modelURL, configuration: MLModelConfiguration())
        } catch {
            NSLog("ML model could not be loaded: %@", error.localizedDescription)
            group.leave()
            return
        }

        let provider = try? MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(multiArray: tensor)])
        guard let provider = provider else {
            group.leave()
            return
        }

        let output: MLFeatureProvider
        do { output = try mlModel.prediction(from: provider) }
        catch {
            NSLog("ML prediction error: %@", error.localizedDescription)
            group.leave()
            return
        }

        guard let scores = output.featureValue(for: "scores")?.multiArrayValue else {
            NSLog("ML output 'scores' not found")
            group.leave()
            return
        }

        func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) * 100 }
        let acneLogit   = Double(truncating: scores[[0, 0] as [NSNumber]])
        let rednessLogit = Double(truncating: scores[[0, 1] as [NSNumber]])

        let acne    = sigmoid(acneLogit)
        let redness = sigmoid(rednessLogit)

        let condition = ["Acne": acne, "Redness": redness]
        let top = condition.max(by: { $0.value < $1.value })

        // Extract heatmaps [1, 5, 12, 12] — only Acne (0) and Redness (1)
        var extractedHeatmaps: [String: [[Float]]] = [:]
        if let hm = output.featureValue(for: "heatmaps")?.multiArrayValue {
            let classMap: [(index: Int, name: String)] = [(0, "Acne"), (1, "Redness")]
            for entry in classMap {
                var grid = [[Float]]()
                var maxVal: Float = 0
                for h in 0..<12 {
                    var row = [Float]()
                    for w in 0..<12 {
                        let val = Float(truncating: hm[[0, entry.index, h, w] as [NSNumber]])
                        if val > maxVal { maxVal = val }
                        row.append(val)
                    }
                    grid.append(row)
                }
                if maxVal > 0 {
                    grid = grid.map { $0.map { $0 / maxVal } }
                }
                extractedHeatmaps[entry.name] = grid
            }
        }

        DispatchQueue.main.async {
            self.currentAcneScore    = acne
            self.currentRednessScore = redness
            self.heatmaps = extractedHeatmaps
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

        // Forehead: top 15% of face box, inset 15% from sides
        let foreheadRect = CGRect(
            x: (box.minX + box.width * 0.15) * imageSize.width,
            y: (box.minY + box.height * 0.85) * imageSize.height,
            width: box.width * 0.70 * imageSize.width,
            height: box.height * 0.12 * imageSize.height
        ).intersection(imageSize)

        // Crow's feet left: outer left of face at eye level (45-60% up from chin)
        let crowsFeetLeftRect = CGRect(
            x: box.minX * imageSize.width,
            y: (box.minY + box.height * 0.45) * imageSize.height,
            width: box.width * 0.20 * imageSize.width,
            height: box.height * 0.15 * imageSize.height
        ).intersection(imageSize)

        // Crow's feet right: outer right of face at eye level
        let crowsFeetRightRect = CGRect(
            x: (box.minX + box.width * 0.80) * imageSize.width,
            y: (box.minY + box.height * 0.45) * imageSize.height,
            width: box.width * 0.20 * imageSize.width,
            height: box.height * 0.15 * imageSize.height
        ).intersection(imageSize)

        // Horizontal edge kernel (detects horizontal lines = wrinkles)
        let horizontalWeights: [CGFloat] = [
            -1, -2, -1,
             0,  0,  0,
             1,  2,  1
        ]

        func wrinkleDensity(in rect: CGRect) -> Double {
            guard !rect.isEmpty else { return 0 }
            let cropped = ciImage.cropped(to: rect)
            let gray = cropped.applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0.0,
                kCIInputContrastKey: 1.5
            ])
            let edges = gray.applyingFilter("CIConvolution3X3", parameters: [
                "inputWeights": CIVector(values: horizontalWeights, count: 9),
                "inputBias": 0.5
            ])
            guard let cgImg = ctx.createCGImage(edges, from: edges.extent) else { return 0 }
            return cgImg.edgeIntensity
        }

        let foreheadScore = wrinkleDensity(in: foreheadRect)
        let crowsLeftScore = wrinkleDensity(in: crowsFeetLeftRect)
        let crowsRightScore = wrinkleDensity(in: crowsFeetRightRect)

        let combined = foreheadScore * 0.50 + crowsLeftScore * 0.25 + crowsRightScore * 0.25
        let finalScore = min(combined * 250, 100)

        NSLog("[WRINKLE] face box: %.2f,%.2f %.2fx%.2f | forehead: %.1f crowsL: %.1f crowsR: %.1f → score: %.1f",
              box.minX, box.minY, box.width, box.height,
              foreheadScore, crowsLeftScore, crowsRightScore, finalScore)

        DispatchQueue.main.async {
            self.wrinkleScore = finalScore
        }
    }

    // MARK: - Eyebag Detection (LAB color difference + texture)
    func calculateEyebagScore(ciImage: CIImage, face: VNFaceObservation) {
        let imageSize = ciImage.extent
        let box = face.boundingBox
        let ctx = CIContext()

        // Under-eye: 52-60% from chin (just below eye level ~60%)
        let underEyeY = (box.minY + box.height * 0.52) * imageSize.height
        let leftEyeRect = CGRect(
            x: (box.minX + box.width * 0.12) * imageSize.width,
            y: underEyeY,
            width: box.width * 0.28 * imageSize.width,
            height: box.height * 0.08 * imageSize.height
        ).intersection(imageSize)

        let rightEyeRect = CGRect(
            x: (box.minX + box.width * 0.60) * imageSize.width,
            y: underEyeY,
            width: box.width * 0.28 * imageSize.width,
            height: box.height * 0.08 * imageSize.height
        ).intersection(imageSize)

        // Cheek reference: 38-45% from chin (mid-cheek area)
        let cheekY = (box.minY + box.height * 0.38) * imageSize.height
        let cheekRect = CGRect(
            x: (box.minX + box.width * 0.20) * imageSize.width,
            y: cheekY,
            width: box.width * 0.60 * imageSize.width,
            height: box.height * 0.08 * imageSize.height
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
        let darknessScore = darknessDiff * 300

        // Texture under eyes indicates puffiness/bags
        let textureScore = avgEyeTex * 200

        let finalScore = min(darknessScore * 0.65 + textureScore * 0.35, 100)

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
            skinType: skinType
        )

        let imageData = capturedImage?.jpegData(compressionQuality: 0.5)

        let record = LocalPersistenceManager.shared.saveAnalysisRecord(
            condition: detectedCondition ?? "Healthy",
            confidence: 0,
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
            self.isAnalyzing = false
            self.heatmaps = [:]
            self.faceRect = .zero
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
            if val > 0.15 { aboveThreshold += 1 }
            count += 1
        }
        return count > 0 ? Double(aboveThreshold) / Double(count) : 0
    }
}

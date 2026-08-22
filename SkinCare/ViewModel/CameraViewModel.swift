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
    @Published var analysisRecord: AnalysisRecord? = nil
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String? = nil

    /// False when the classifier failed, so a broken run never persists a
    /// record that would read as a flawless complexion.
    private var didProduceModelScores = false
    /// The package is ~53 MB; loading it per capture cost seconds.
    private var cachedModel: MLModel?

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
            self.didProduceModelScores = false
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
        do {
            try handler.perform([request])
        } catch {
            // Without this the completion never fires and the awaiting task
            // would hang forever with the UI stuck on "Analyzing".
            NSLog("Face detection failed: %@", error.localizedDescription)
            completion(nil, .zero)
        }
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

        func logit(_ index: Int) -> Double {
            Double(truncating: scores[[0, NSNumber(value: index)] as [NSNumber]])
        }

        let acne = ModelCalibration.score(fromLogit: logit(ModelCalibration.Index.acne))
        let redness = ModelCalibration.score(fromLogit: logit(ModelCalibration.Index.redness))
        let eyebags = ModelCalibration.score(fromLogit: logit(ModelCalibration.Index.eyebags))
        let wrinkles = ModelCalibration.score(fromLogit: logit(ModelCalibration.Index.wrinkles))

        // A condition is only named when it clears its calibrated threshold,
        // so a model with no opinion reports Healthy instead of a middling score.
        let candidates: [(name: String, score: Double, threshold: Double)] = [
            ("Acne", acne, ModelCalibration.acneThreshold * 100),
            ("Redness", redness, ModelCalibration.rednessThreshold * 100)
        ]
        let detected = candidates
            .filter { $0.score >= $0.threshold }
            .max(by: { $0.score < $1.score })

        DispatchQueue.main.async {
            self.currentAcneScore = acne
            self.currentRednessScore = redness
            self.eyebagScore = eyebags
            self.wrinkleScore = wrinkles
            self.detectedCondition = detected?.name ?? "Healthy"
            self.didProduceModelScores = true
        }
    }

    /// Pigmentation is derived on device from the same face crop; nothing
    /// leaves the phone.
    func analyzeSecondaryConditions(_ image: UIImage) async {
        let pigmentation = PigmentationAnalyzer.analyze(image)
        await MainActor.run {
            self.pigmentationScore = pigmentation
        }
    }

    func buildRecord() {
        // A failed classification must not persist a record: the all-zero
        // severities would score as flawless skin and would still burn one of
        // the user's five monthly scans.
        guard didProduceModelScores else {
            self.isAnalyzing = false
            if self.errorMessage == nil {
                self.errorMessage = NSLocalizedString("analysis_error_model", comment: "")
            }
            return
        }

        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        let skinType = profile?.skinType?.lowercased() ?? "normal"
        let skinScores = engine.calculateScore(
            acne: currentAcneScore / 100,
            redness: currentRednessScore / 100,
            pigmentation: pigmentationScore / 100,
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
            self.didProduceModelScores = false
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

import AVFoundation
import SwiftUI
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

    @Published var hydrationScore: Double = 0

    /// False when the analysis failed, so a broken run never persists a
    /// record that would read as a flawless complexion.
    private var didProduceModelScores = false

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
        // checkPermission() runs on every appear and foreground; once the
        // session is configured, only make sure it is running again instead
        // of re-locking the device and re-adding inputs on the main thread.
        guard session.inputs.isEmpty else {
            startSessionIfNeeded()
            return
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            AppLog.error("No front camera available")
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
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.unlockForConfiguration()
            }
        } catch {
            AppLog.error("Camera setup failed", error)
        }

        session.commitConfiguration()

        startSessionIfNeeded()
    }

    private func startSessionIfNeeded() {
        DispatchQueue.global(qos: .background).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func capturePhoto() {
        guard session.isRunning else { return }
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

            await self.analyzeWithCloud(imageToAnalyze)

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

    private func detectFaceAndCrop(_ image: UIImage, completion rawCompletion: @escaping (UIImage?, CGRect) -> Void) {
        // Vision can invoke the request's completion handler with an error
        // and then still make perform() throw, which would fire completion
        // twice — fatal for the checked continuation awaiting it.
        var hasFired = false
        let completion: (UIImage?, CGRect) -> Void = { image, rect in
            guard !hasFired else { return }
            hasFired = true
            rawCompletion(image, rect)
        }

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
            AppLog.error("Face detection failed", error)
            completion(nil, .zero)
        }
    }

    /// Sends the face crop to the analysis proxy and fills all six scores.
    ///
    /// On any failure it leaves `didProduceModelScores` false, so
    /// `buildRecord()` refuses to persist: an all-zero record would read as
    /// flawless skin, and it would still burn one of the user's five monthly
    /// scans.
    func analyzeWithCloud(_ image: UIImage) async {
        // The persistence manager wraps the main-queue viewContext; fetching
        // from this background task would be a Core Data threading violation.
        let (skinType, age) = await MainActor.run { () -> (String?, Int?) in
            let profile = LocalPersistenceManager.shared.fetchUserProfile()
            // ageRange can be a bare number ("30") or a range ("25-34");
            // Int() on the whole string silently drops the range form.
            let age = profile?.ageRange
                .flatMap { Int($0.prefix(while: \.isNumber)) }
            return (profile?.skinType?.lowercased(), age)
        }

        do {
            let scores = try await AnalysisService.shared.analyze(
                image: image, skinType: skinType, age: age
            )
            await MainActor.run {
                self.currentAcneScore = scores.acne
                self.currentRednessScore = scores.redness
                self.wrinkleScore = scores.wrinkles
                self.eyebagScore = scores.eyebags
                self.pigmentationScore = scores.pigmentation
                self.hydrationScore = scores.hydration

                // Same naming rule the calibrated on-device model used: a
                // condition is called out only above its cut-off, and only
                // the primary two get a name.
                let candidates: [(name: String, score: Double, threshold: Double)] = [
                    ("Acne", scores.acne, AnalysisService.acneThreshold),
                    ("Redness", scores.redness, AnalysisService.rednessThreshold)
                ]
                let detected = candidates
                    .filter { $0.score >= $0.threshold }
                    .max(by: { $0.score < $1.score })
                self.detectedCondition = detected?.name ?? "Healthy"
                self.didProduceModelScores = true
            }
        } catch {
            AppLog.error("Cloud analysis failed", error)
            let messageKey: String
            switch error {
            case AnalysisError.encodingFailed:
                messageKey = "analysis_error_photo"
            case AnalysisError.server(let code):
                // Rate limits and the daily spend ceiling are "try later",
                // not "check your connection".
                let busyCodes = ["http_429", "rate_limited", "daily_budget_exceeded"]
                messageKey = busyCodes.contains(code) ? "analysis_error_busy" : "analysis_error_server"
            default:
                messageKey = "analysis_error_network"
            }
            await MainActor.run {
                self.errorMessage = NSLocalizedString(messageKey, comment: "")
            }
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
            hydration: hydrationScore / 100,
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
            inflammationScore: skinScores.inflammationScore,
            oilinessScore: skinScores.oilinessScore,
            overallScore: skinScores.overallScore,
            acneScore: currentAcneScore,
            eczemaScore: currentRednessScore,
            hydrationScore: hydrationScore,
            imageData: imageData
        )

        // A record that failed to persist would vanish on the next launch;
        // treat it like any other failed analysis and spare the scan quota.
        guard let record else {
            self.isAnalyzing = false
            self.errorMessage = NSLocalizedString("analysis_error_model", comment: "")
            return
        }

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
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

import AVFoundation
import SwiftUI
internal import Combine

class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isPermissionGranted = false
    
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
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print("camera setup error: \(error.localizedDescription)")
        }
    }
}

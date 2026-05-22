import SwiftUI
import AVFoundation
import Lottie
internal import Combine

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("hasSeenCameraGuide") private var hasSeenCameraGuide = false
    @State private var showGuide = false
    @State private var showResult = false
    @State private var showQuotaAlert = false
    @State private var showUpgrade = false
    
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Face Analysis")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(primaryText)

                    Text("Position your face within the oval frame")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                // Scan quota badge (free users only)
                if !subscriptionManager.isPremium {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.badge.clock")
                            .font(.system(size: 13))
                        Text(subscriptionManager.scansRemaining == 0
                             ? "Monthly scanning limit has expired."
                             : "\(subscriptionManager.scansRemaining) scans left.")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(subscriptionManager.scansRemaining == 0 ? .red : secondaryColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(subscriptionManager.scansRemaining == 0
                                ? Color.red.opacity(0.08)
                                : Color(red: 1.0, green: 0.87, blue: 0.87))
                    .cornerRadius(20)
                }
                
                Spacer()
                
                ZStack {
                    // Live Camera or Captured Image
                    Group {
                        if vm.permissionStatus == .denied {
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                                        .frame(width: 100, height: 100)
                                    Circle()
                                        .fill(secondaryColor)
                                        .frame(width: 68, height: 68)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }

                                Text("Camera Access Required")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(primaryText)

                                Text("To analyze your skin, we need access to your camera. Your photos never leave your device.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)

                                Button {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "gear")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Open Settings")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(secondaryColor)
                                    .cornerRadius(14)
                                }
                            }
                            .frame(width: 350, height: 440)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                        } else if vm.permissionStatus == .notDetermined {
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.87, blue: 0.87))
                                        .frame(width: 100, height: 100)
                                    Circle()
                                        .fill(secondaryColor)
                                        .frame(width: 68, height: 68)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }

                                Text("Ready to Scan?")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(primaryText)

                                Text("Enable camera access to start your skin analysis journey.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)

                                Button {
                                    vm.requestPermission()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Enable Camera")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(secondaryColor)
                                    .cornerRadius(14)
                                }
                            }
                            .frame(width: 350, height: 440)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                        } else if let captured = vm.capturedImage {
                            Image(uiImage: captured)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 440)
                                .cornerRadius(30)
                                .clipped()
                                .transition(.opacity)
                        } else {
                            CameraPreview(session: vm.session)
                                .frame(width: 350, height: 440)
                                .cornerRadius(30)
                                .clipped()
                                .background(Color.gray.opacity(0.05))
                        }
                    }

                    // 2. Scanning UI (Lottie Animation)
                    if vm.isAnalyzing {
                        LottieView(animation: .named("scanning"))
                            .playing(loopMode: .loop)
                            .configure { animationView in
                                let color = ColorValueProvider(UIColor(red: 0.47, green: 0.11, blue: 0.17, alpha: 1.0).lottieColorValue)
                                animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Color"))
                                animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Fill.Color"))
                                animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Stroke.Color"))
                                animationView.contentMode = .scaleAspectFill
                            }
                            .frame(width: 360, height: 450)
                            .scaleEffect(1.1) // Force a slight overflow to ensure full coverage
                            .clipped()
                            .transition(.opacity)
                    }


                    // Static Guides & Center Indicators
                    if vm.permissionStatus == .authorized {
                        RoundedRectangle(cornerRadius: 35)
                            .stroke(secondaryColor, lineWidth: 4)
                            .frame(width: 360, height: 450)
                            .mask(
                                ZStack {
                                    VStack {
                                        HStack {
                                            Rectangle().frame(width: 60, height: 60)
                                            Spacer()
                                            Rectangle().frame(width: 60, height: 60)
                                        }
                                        Spacer()
                                        HStack {
                                            Rectangle().frame(width: 60, height: 60)
                                            Spacer()
                                            Rectangle().frame(width: 60, height: 60)
                                        }
                                    }
                                }
                            )

                        if !vm.isAnalyzing && vm.capturedImage == nil {
                            Ellipse()
                                .stroke(secondaryColor, style: StrokeStyle(lineWidth: 2, dash: [6]))
                                .frame(width: 220, height: 300)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(secondaryColor.opacity(0.2))
                        }
                    }
                }
                .frame(width: 360, height: 450)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut, value: vm.isAnalyzing)
                
                Spacer()
                
                Button(action: {
                    guard !vm.isAnalyzing else { return }
                    guard subscriptionManager.canScan else {
                        showQuotaAlert = true
                        return
                    }
                    
                    vm.capturePhoto()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: vm.isAnalyzing ? "hourglass" : "viewfinder")
                            .font(.system(size: 20, weight: .bold))

                        Text(vm.isAnalyzing ? "Analyzing..." : "Start Analysis")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        (vm.isAnalyzing || !vm.isPermissionGranted) 
                        ? secondaryColor.opacity(0.5) 
                        : secondaryColor
                    )
                    .cornerRadius(16)
                    .shadow(color: secondaryColor.opacity(vm.isPermissionGranted ? 0.3 : 0), radius: 10, x: 0, y: 5)
                }
                .disabled(vm.isAnalyzing || !vm.isPermissionGranted)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        
        .alert("Scan Limit Reached", isPresented: $showQuotaAlert) {
            Button("Go Pro") { showUpgrade = true }
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've used your \(SubscriptionManager.shared.freeMonthlyLimit) free monthly scans. Go Pro for unlimited analysis.")
        }
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .onAppear {
            if !hasSeenCameraGuide {
                showGuide = true
            }
            vm.checkPermission()
            vm.resetScanner()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            vm.checkPermission()
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $showGuide, onDismiss: {
            if vm.permissionStatus == .notDetermined {
                vm.requestPermission()
            }
        }) {
            CameraGuideView()
        }
        .onChange(of: vm.analysisRecord) { oldValue, newValue in
            if vm.capturedImage != nil && newValue != nil {
                showResult = true
            }
        }
        .fullScreenCover(isPresented: $showResult, onDismiss: {
            vm.resetScanner()
        }) {
            ResultView(record: vm.analysisRecord, isFromRecents: false) {
                showResult = false
                vm.resetScanner()
            }
        }
    }
    
    struct CameraPreview: UIViewRepresentable {
        let session: AVCaptureSession
        
        func makeUIView(context: Context) -> UIView {
            let view = VideoPreviewView()
            view.backgroundColor = .lightGray
            view.videoPreviewLayer.session = session
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
        
        class VideoPreviewView: UIView {
            override class var layerClass: AnyClass {
                return AVCaptureVideoPreviewLayer.self
            }
            
            var videoPreviewLayer: AVCaptureVideoPreviewLayer {
                return layer as! AVCaptureVideoPreviewLayer
            }
        }
    }
}

#Preview {
    CameraView()
}

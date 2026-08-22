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
    /// TabView keeps this view alive across tab switches, so notification
    /// observers fire even while another tab is showing. Only react when visible.
    @State private var isCameraVisible = false

    var body: some View {
        GeometryReader { geo in
            let previewWidth = min(geo.size.width - 48, 360)
            let previewHeight = previewWidth * 1.25

            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("face_analysis", comment: ""))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.brandText)

                        Text(NSLocalizedString("position_face", comment: ""))
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
                                 ? AppStrings.monthlyScanLimitExpired
                                 : String(format: AppStrings.scansLeft, subscriptionManager.scansRemaining))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(subscriptionManager.scansRemaining == 0 ? .brandNegative : .brandPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(subscriptionManager.scansRemaining == 0
                                    ? Color.brandNegative.opacity(0.08)
                                    : Color.brandBlush)
                        .cornerRadius(Radius.card)
                    }

                    Spacer()

                    ZStack {
                        // Live Camera or Captured Image
                        Group {
                            if vm.permissionStatus == .denied {
                                permissionCard(
                                    title: NSLocalizedString("camera_access_required", comment: ""),
                                    description: NSLocalizedString("camera_access_description", comment: ""),
                                    buttonIcon: "gear",
                                    buttonTitle: NSLocalizedString("open_settings", comment: ""),
                                    size: CGSize(width: previewWidth, height: previewHeight)
                                ) {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            } else if vm.permissionStatus == .notDetermined {
                                permissionCard(
                                    title: NSLocalizedString("ready_to_scan", comment: ""),
                                    description: NSLocalizedString("enable_camera_description", comment: ""),
                                    buttonIcon: "camera.fill",
                                    buttonTitle: NSLocalizedString("enable_camera", comment: ""),
                                    size: CGSize(width: previewWidth, height: previewHeight)
                                ) {
                                    vm.requestPermission()
                                }
                            } else if let captured = vm.capturedImage {
                                Image(uiImage: captured)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: previewWidth, height: previewHeight)
                                    .cornerRadius(Radius.card)
                                    .clipped()
                                    .transition(.opacity)
                            } else {
                                CameraPreview(session: vm.session)
                                    .frame(width: previewWidth, height: previewHeight)
                                    .cornerRadius(Radius.card)
                                    .clipped()
                                    .background(Color.gray.opacity(0.05))
                            }
                        }

                        // 2. Scanning UI (Lottie Animation)
                        if vm.isAnalyzing {
                            LottieView(animation: .named("scanning"))
                                .playing(loopMode: .loop)
                                .configure { animationView in
                                    let color = ColorValueProvider(UIColor(Color.brandPrimary).lottieColorValue)
                                    animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Color"))
                                    animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Fill.Color"))
                                    animationView.setValueProvider(color, keypath: AnimationKeypath(keypath: "**.Stroke.Color"))
                                    animationView.contentMode = .scaleAspectFill
                                }
                                .frame(width: previewWidth, height: previewHeight)
                                .scaleEffect(1.1) // Force a slight overflow to ensure full coverage
                                .clipped()
                                .transition(.opacity)
                        }

                        // Static Guides & Center Indicators
                        if vm.permissionStatus == .authorized {
                            RoundedRectangle(cornerRadius: Radius.card)
                                .stroke(Color.brandPrimary, lineWidth: 4)
                                .frame(width: previewWidth, height: previewHeight)
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
                                    .stroke(Color.brandPrimary, style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .frame(width: previewWidth * 0.61, height: previewHeight * 0.67)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color.brandPrimary.opacity(0.2))
                            }
                        }
                    }
                    .frame(width: previewWidth, height: previewHeight)
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.25), value: vm.isAnalyzing)

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

                            Text(vm.isAnalyzing ? AppStrings.analyzing : AppStrings.startAnalysis)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: !vm.isAnalyzing && vm.isPermissionGranted))
                    .disabled(vm.isAnalyzing || !vm.isPermissionGranted)
                    .padding(.bottom, 12)

                }
                .padding(.horizontal, 24)
            }
        }
        .alert(NSLocalizedString("analysis_failed_title", comment: ""), isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button(AppStrings.ok, role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert(AppStrings.scanLimitReached, isPresented: $showQuotaAlert) {
            Button(AppStrings.goPro) { showUpgrade = true }
            Button(AppStrings.ok, role: .cancel) {}
        } message: {
            Text(String(format: NSLocalizedString("free_scans_used", comment: ""), SubscriptionManager.shared.freeMonthlyLimit))
        }
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .onAppear {
            isCameraVisible = true
            if !hasSeenCameraGuide {
                showGuide = true
            }
            vm.checkPermission()
            vm.resetScanner()
        }
        .onDisappear {
            isCameraVisible = false
            vm.stopSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if isCameraVisible {
                vm.checkPermission()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            vm.stopSession()
        }
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

    @ViewBuilder
    private func permissionCard(
        title: String,
        description: String,
        buttonIcon: String,
        buttonTitle: String,
        size: CGSize,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 20) {
            BrandCircleIcon(systemImage: "camera.fill", size: 100)

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.brandText)

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 15, weight: .semibold))
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Color.brandPrimary)
                .cornerRadius(Radius.card)
            }
        }
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: Radius.card)
                .fill(Color.white)
        )
        .cardShadow()
    }

    struct CameraPreview: UIViewRepresentable {
        let session: AVCaptureSession

        func makeUIView(context: Context) -> UIView {
            let view = VideoPreviewView()
            view.backgroundColor = .lightGray
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            // Attaching the session here runs inside SwiftUI's layout pass;
            // AVFoundation commits its configuration on a nested run loop,
            // which re-enters layout and crashes (AttributeGraph abort).
            // Defer the attachment until the current update finishes.
            let session = self.session
            DispatchQueue.main.async {
                view.videoPreviewLayer.session = session
            }
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

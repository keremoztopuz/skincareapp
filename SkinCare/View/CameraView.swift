import SwiftUI
import AVFoundation
internal import Combine

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("hasSeenCameraGuide") private var hasSeenCameraGuide = false
    @State private var showGuide = false
    @State private var showResult = false
    @State private var scanOffset: CGFloat = -210
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
                    if vm.isAnalyzing, let captured = vm.capturedImage {
                        Image(uiImage: captured)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 340, height: 420)
                            .cornerRadius(30)
                            .clipped()

                        // Scan line
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            secondaryColor.opacity(0),
                                            secondaryColor.opacity(0.6),
                                            secondaryColor.opacity(0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 340, height: 40)

                            Rectangle()
                                .fill(secondaryColor)
                                .frame(width: 340, height: 2)
                        }
                        .offset(y: scanOffset)
                        .frame(width: 340, height: 420)
                        .cornerRadius(30)
                        .clipped()

                        // Scanning label
                        VStack {
                            Spacer()
                            Text("Scanning...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(secondaryColor.opacity(0.7))
                                .cornerRadius(10)
                                .padding(.bottom, 16)
                        }
                        .frame(width: 340, height: 420)

                    } else {
                        CameraPreview(session: vm.session)
                            .frame(width: 340, height: 420)
                            .cornerRadius(30)
                            .clipped()
                            .background(Color.gray.opacity(0.05))
                    }

                    RoundedRectangle(cornerRadius: 35)
                        .stroke(secondaryColor, lineWidth: 4)
                        .frame(width: 350, height: 430)
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

                    if !vm.isAnalyzing {
                        Ellipse()
                            .stroke(secondaryColor, style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .frame(width: 220, height: 300)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(secondaryColor.opacity(0.2))
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    guard !vm.isAnalyzing else { return }
                    guard subscriptionManager.canScan else {
                        showQuotaAlert = true
                        return
                    }
                    scanOffset = -210
                    vm.capturePhoto()
                    withAnimation(.linear(duration: 1.8)) {
                        scanOffset = 210
                    }
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
                    .background(vm.isAnalyzing ? secondaryColor.opacity(0.6) : secondaryColor)
                    .cornerRadius(16)
                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(vm.isAnalyzing)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        
        .alert("Scan Hakkın Doldu", isPresented: $showQuotaAlert) {
            Button("Pro'ya Geç") { showUpgrade = true }
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Aylık \(SubscriptionManager.shared.freeMonthlyLimit) ücretsiz scan hakkını kullandın. Pro'ya geç ve sınırsız analiz yap.")
        }
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .onAppear {
            if !hasSeenCameraGuide {
                showGuide = true
            }
            vm.checkPermission()
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $showGuide) {
            CameraGuideView()
        }
        .onChange(of: vm.analysisRecord) { oldValue, newValue in
            if vm.capturedImage != nil {
                scanOffset = -210
                showResult = true
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(record: vm.analysisRecord, isFromRecents: false)
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

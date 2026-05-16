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
                    // 1. Live Camera or Captured Image
                    Group {
                        if let captured = vm.capturedImage {
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
                                .overlay {
                                    if vm.isAnalyzing {
                                        // "Fake" freeze with blur while waiting for high-res photo
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                    }
                                }
                        }
                    }

                    // 2. Scanning UI (Always visible during analysis, regardless of image arrival)
                    if vm.isAnalyzing {
                        ZStack {
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
                                    .frame(width: 350, height: 40)

                                Rectangle()
                                    .fill(secondaryColor)
                                    .frame(width: 350, height: 2)
                            }
                            .offset(y: scanOffset)
                            .frame(width: 350, height: 440)
                            .clipped()

                            // Scanning label
                            VStack {
                                Spacer()
                                Text("Analyzing Skin...")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(secondaryColor.opacity(0.8))
                                    .cornerRadius(12)
                                    .padding(.bottom, 20)
                            }
                        }
                        .transition(.opacity)
                    }

                    // 3. Static Guides
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

                    if !vm.isAnalyzing {
                        Ellipse()
                            .stroke(secondaryColor, style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .frame(width: 220, height: 300)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(secondaryColor.opacity(0.2))
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
                    
                    // Reset and start scan line animation
                    scanOffset = -210
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
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
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $showGuide) {
            CameraGuideView()
        }
        .onChange(of: vm.analysisRecord) { oldValue, newValue in
            if vm.capturedImage != nil && newValue != nil {
                scanOffset = -210
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
        .onChange(of: vm.isAnalyzing) { oldValue, newValue in
            if newValue {
                // Instant animation trigger
                scanOffset = -210
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    scanOffset = 210
                }
            } else {
                scanOffset = -210
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

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Face Analysis")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(primaryText)
                            
                    Text("Position your face within the oval frame")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Analysis Frame
                ZStack {
                    // Camera Card
                    CameraPreview(session: vm.session)
                        .frame(width: 340, height: 420)
                        .cornerRadius(30)
                        .clipped()
                        .background(Color.gray.opacity(0.1))
                    
                    // Perfect Corner Marks (5 units offset from the main card)
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
                    
                    // Dashed Oval
                    Ellipse()
                        .stroke(secondaryColor, style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .frame(width: 220, height: 300)
                    
                    // Center Icon
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(secondaryColor.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Analysis Button
                Button(action: {
                    print("Analysis started")
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Start Analysis")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(secondaryColor)
                    .cornerRadius(16)
                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { vm.checkPermission() }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = CGRect(x: 0, y: 0, width: 340, height: 420)
        }
    }
}

#Preview {
    CameraView()
}

import SwiftUI

struct CameraView: View {
    var body: some View {
        let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
        let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
        
        ZStack {
            mainColor.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Face Analysis")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            
                    Text("Position your face within the oval frame")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Analysis Frame
                ZStack {
                    // Background Card
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 340, height: 420)
                    
                    // Corner Marks
                    Group {
                        // Top Left
                        cornerMark(color: secondaryColor)
                            .offset(x: -170, y: -210)
                        // Top Right
                        cornerMark(color: secondaryColor)
                            .rotationEffect(.degrees(90))
                            .offset(x: 170, y: -210)
                        // Bottom Left
                        cornerMark(color: secondaryColor)
                            .rotationEffect(.degrees(-90))
                            .offset(x: -170, y: 210)
                        // Bottom Right
                        cornerMark(color: secondaryColor)
                            .rotationEffect(.degrees(180))
                            .offset(x: 170, y: 210)
                    }
                    
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
    }
    
    // Helper for Corner Marks
    func cornerMark(color: Color) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(color)
                .frame(width: 40, height: 4)
                .cornerRadius(2)
            Rectangle()
                .fill(color)
                .frame(width: 4, height: 40)
                .cornerRadius(2)
        }
    }
}

#Preview {
    CameraView()
}

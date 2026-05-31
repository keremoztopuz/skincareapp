import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct HeatmapOverlayView: View {
    let faceImage: UIImage
    let heatmap: [[Float]]
    let conditionName: String
    let faceRect: CGRect  // normalized 0-1, UIKit coords (origin top-left)
    @Environment(\.dismiss) var dismiss

    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)

    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(secondaryColor)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("\(conditionName) Map")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(primaryText)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 34, height: 34)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                ZStack {
                    Image(uiImage: faceImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                    if let overlayImage = renderSmoothHeatmap() {
                        Image(uiImage: overlayImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                HStack(spacing: 4) {
                    ForEach(0..<5) { i in
                        let fraction = Double(i) / 4.0
                        Rectangle()
                            .fill(legendColor(fraction))
                            .frame(height: 8)
                    }
                }
                .clipShape(Capsule())
                .padding(.horizontal, 40)

                HStack {
                    Text(NSLocalizedString("low", comment: ""))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(NSLocalizedString("high", comment: ""))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 44)

                Text(String(format: NSLocalizedString("heatmap_description", comment: ""), conditionName.lowercased()))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()
            }
        }
    }

    private func renderSmoothHeatmap() -> UIImage? {
        let rows = heatmap.count
        guard rows > 0 else { return nil }
        let cols = heatmap[0].count
        let outW = Int(faceImage.size.width)
        let outH = Int(faceImage.size.height)
        guard outW > 0, outH > 0 else { return nil }

        // Face region in pixel coordinates
        let fX = Int(faceRect.origin.x * CGFloat(outW))
        let fY = Int(faceRect.origin.y * CGFloat(outH))
        let fW = Int(faceRect.width * CGFloat(outW))
        let fH = Int(faceRect.height * CGFloat(outH))
        let hasFace = fW > 0 && fH > 0

        var pixels = [UInt8](repeating: 0, count: outW * outH * 4)

        for py in 0..<outH {
            for px in 0..<outW {
                // Skip pixels outside face region
                if hasFace {
                    if px < fX || px >= fX + fW || py < fY || py >= fY + fH { continue }
                }

                let relX: Float
                let relY: Float
                if hasFace {
                    let dx = Float(px) - Float(fX)
                    let dy = Float(py) - Float(fY)
                    relX = dx / Float(fW) * Float(cols) - 0.5
                    relY = dy / Float(fH) * Float(rows) - 0.5
                } else {
                    relX = Float(px) / Float(outW) * Float(cols) - 0.5
                    relY = Float(py) / Float(outH) * Float(rows) - 0.5
                }

                let val = bilinearSample(gx: relX, gy: relY, rows: rows, cols: cols)
                let thresholded: Float = max(0, (val - 0.3) / 0.7)

                let pixOffset = (py * outW + px) * 4
                if thresholded < 0.01 {
                    continue
                } else {
                    var edgeFade: Float = 1.0
                    if hasFace {
                        let dL = Float(px) - Float(fX)
                        let dR = Float(fX + fW) - Float(px)
                        let dT = Float(py) - Float(fY)
                        let dB = Float(fY + fH) - Float(py)
                        let fwF = Float(fW)
                        let fhF = Float(fH)
                        let minH = min(dL / fwF, dR / fwF)
                        let minV = min(dT / fhF, dB / fhF)
                        let minDist = min(minH, minV)
                        edgeFade = min(1.0, minDist / 0.08)
                    }

                    let (r, g, b, a) = heatRGBA(thresholded)
                    let fadedAlpha = UInt8(Float(a) * edgeFade)
                    pixels[pixOffset] = r
                    pixels[pixOffset + 1] = g
                    pixels[pixOffset + 2] = b
                    pixels[pixOffset + 3] = fadedAlpha
                }
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &pixels,
            width: outW, height: outH,
            bitsPerComponent: 8, bytesPerRow: outW * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let cgImg = ctx.makeImage() else { return nil }

        let blurSize = hasFace ? fW : max(outW, outH)
        let blurRadius = Double(blurSize) * 0.03
        let bounds = CGRect(x: 0, y: 0, width: outW, height: outH)
        let ciImage = CIImage(cgImage: cgImg)
            .applyingGaussianBlur(sigma: blurRadius)
            .cropped(to: bounds)

        let ciCtx = CIContext()
        guard let blurred = ciCtx.createCGImage(ciImage, from: bounds) else { return nil }

        return UIImage(cgImage: blurred)
    }

    private func bilinearSample(gx: Float, gy: Float, rows: Int, cols: Int) -> Float {
        let x0 = max(0, min(cols - 1, Int(floor(gx))))
        let x1 = min(cols - 1, x0 + 1)
        let y0 = max(0, min(rows - 1, Int(floor(gy))))
        let y1 = min(rows - 1, y0 + 1)

        let fx = max(0, min(1, gx - Float(x0)))
        let fy = max(0, min(1, gy - Float(y0)))

        let v00 = heatmap[y0][x0]
        let v10 = heatmap[y0][x1]
        let v01 = heatmap[y1][x0]
        let v11 = heatmap[y1][x1]

        let top = v00 * (1 - fx) + v10 * fx
        let bot = v01 * (1 - fx) + v11 * fx
        return top * (1 - fy) + bot * fy
    }

    private func heatRGBA(_ v: Float) -> (UInt8, UInt8, UInt8, UInt8) {
        let t: Float = v
        let r: Float = 0.1 + t * 0.37
        let g: Float = 0.1 + t * 0.01
        let b: Float = 0.2 + t * (-0.03)
        let a: Float = t * 200.0
        let r8 = UInt8(clamping: Int(r * 255.0))
        let g8 = UInt8(clamping: Int(g * 255.0))
        let b8 = UInt8(clamping: Int(b * 255.0))
        let a8 = UInt8(clamping: Int(a))
        return (r8, g8, b8, a8)
    }

    private func legendColor(_ value: Double) -> Color {
        let t = value
        return Color(
            red: 0.1 + t * (0.47 - 0.1),
            green: 0.1 + t * (0.11 - 0.1),
            blue: 0.2 + t * (0.17 - 0.2)
        )
    }
}

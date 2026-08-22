//
//  PigmentationAnalyzer.swift
//  SkinCare
//

import CoreImage
import UIKit

/// Measures pigmentation evenness entirely on device.
///
/// Pigmentation is not a diagnosis, it is a colour statistic: how uniform the
/// melanin distribution across the face is. This converts the face crop to
/// CIELAB and measures the spread of the Individual Typology Angle (ITA°),
/// the standard descriptor used in cosmetic science. Working in ITA° rather
/// than raw luminance makes the result independent of the person's base skin
/// tone, so a dark and a light complexion with equally even pigmentation
/// score the same.
enum PigmentationAnalyzer {

    private static let context = CIContext(options: [.useSoftwareRenderer: false])

    /// Returns a 0-100 score where higher means more uneven pigmentation.
    static func analyze(_ image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0 }

        // Sample the central face region, avoiding hairline and background.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let region = CGRect(x: width * 0.15, y: height * 0.20,
                            width: width * 0.70, height: height * 0.60)
        guard let cropped = cgImage.cropping(to: region) else { return 0 }

        guard let samples = downsampledRGB(cropped, side: 96) else { return 0 }

        var angles: [Double] = []
        angles.reserveCapacity(samples.count)
        for (r, g, b) in samples {
            let (lStar, _, bStar) = labComponents(r: r, g: g, b: b)
            // Skip near-black and blown-out pixels: shadows and specular
            // highlights carry no pigmentation information.
            guard lStar > 15, lStar < 95 else { continue }
            angles.append(atan2(lStar - 50.0, bStar) * 180.0 / .pi)
        }

        guard angles.count > 100 else { return 0 }

        // Robust spread: the 10-90 percentile range resists a few stray
        // pixels far better than a standard deviation would.
        angles.sort()
        let low = angles[Int(Double(angles.count) * 0.10)]
        let high = angles[Int(Double(angles.count) * 0.90)]
        let spread = high - low

        // An even complexion sits near 8-10 degrees of spread; 35 degrees and
        // above is markedly blotchy. Mapped linearly and clamped.
        let normalized = (spread - 8.0) / (35.0 - 8.0)
        return min(max(normalized * 100.0, 0.0), 100.0)
    }

    // MARK: - Helpers

    private static func downsampledRGB(_ cgImage: CGImage, side: Int) -> [(Double, Double, Double)]? {
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        guard let ctx = CGContext(data: &pixels, width: side, height: side,
                                  bitsPerComponent: 8, bytesPerRow: side * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            return nil
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: side, height: side))

        var result: [(Double, Double, Double)] = []
        result.reserveCapacity(side * side)
        for i in stride(from: 0, to: pixels.count, by: 4) {
            result.append((Double(pixels[i]) / 255.0,
                           Double(pixels[i + 1]) / 255.0,
                           Double(pixels[i + 2]) / 255.0))
        }
        return result
    }

    /// sRGB to CIELAB under a D65 illuminant.
    private static func labComponents(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
        func linearize(_ channel: Double) -> Double {
            channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        let rl = linearize(r), gl = linearize(g), bl = linearize(b)

        let x = (rl * 0.4124 + gl * 0.3576 + bl * 0.1805) / 0.95047
        let y = (rl * 0.2126 + gl * 0.7152 + bl * 0.0722)
        let z = (rl * 0.0193 + gl * 0.1192 + bl * 0.9505) / 1.08883

        func f(_ t: Double) -> Double {
            t > 0.008856 ? pow(t, 1.0 / 3.0) : (7.787 * t) + (16.0 / 116.0)
        }
        let fx = f(x), fy = f(y), fz = f(z)

        return (116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))
    }
}

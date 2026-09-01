//
//  ConditionZoneOverlay.swift
//  SkinCare
//

import SwiftUI

/// Maps image coordinates into the view space of a center-anchored
/// aspect-fill, the way `.scaledToFill()` lays an image into a fixed frame.
/// Pure math, unit-tested; points may map outside the container and are
/// clipped by whatever shape the photo already clips to.
enum AspectFillMapper {
    static func transform(imageSize: CGSize, containerSize: CGSize) -> CGAffineTransform {
        guard imageSize.width > 0, imageSize.height > 0 else { return .identity }
        let scale = max(containerSize.width / imageSize.width,
                        containerSize.height / imageSize.height)
        let tx = (containerSize.width - imageSize.width * scale) / 2
        let ty = (containerSize.height - imageSize.height * scale) / 2
        return CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(translationX: tx, y: ty))
    }
}

/// SplitMix64 — a tiny deterministic generator. `SystemRandomNumberGenerator`
/// would redraw every blob differently on every render and the marks would
/// shimmer; seeding from the region itself keeps each spot's shape fixed.
struct SeededGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// Uniform in [0, 1).
    mutating func nextUnit() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

/// A softly irregular spot: an ellipse inscribed in the rect whose radius
/// wobbles with a seeded generator, smoothed into a closed Catmull-Rom
/// spline. An elongated rect yields a line-shaped mark, a squarish one a
/// dot — the model's box decides the character of the spot.
struct OrganicBlobShape: Shape {
    let seed: UInt64
    var anchorCount: Int = 10

    func path(in rect: CGRect) -> Path {
        guard rect.width > 0, rect.height > 0, anchorCount >= 3 else { return Path() }

        var generator = SeededGenerator(seed: seed)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let anchors: [CGPoint] = (0..<anchorCount).map { index in
            let angle = Double(index) / Double(anchorCount) * 2 * .pi
            // 0.82…1.12 of the inscribed radius: irregular, never spiky.
            let wobble = 0.82 + 0.30 * generator.nextUnit()
            return CGPoint(
                x: center.x + CGFloat(cos(angle) * wobble) * rect.width / 2,
                y: center.y + CGFloat(sin(angle) * wobble) * rect.height / 2
            )
        }

        // Closed Catmull-Rom through the anchors, as cubic Béziers — the
        // spline interpolates every anchor, so the wobble stays bounded.
        var path = Path()
        path.move(to: anchors[0])
        let count = anchors.count
        for index in 0..<count {
            let p0 = anchors[(index - 1 + count) % count]
            let p1 = anchors[index]
            let p2 = anchors[(index + 1) % count]
            let p3 = anchors[(index + 2) % count]
            path.addCurve(
                to: p2,
                control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            )
        }
        path.closeSubpath()
        return path
    }
}

/// The selected condition's regions drawn over the scanned photo as organic,
/// soft-edged marks in the brand colour, their depth following the severity.
/// The model localizes reliably only as boxes, so the box gives the mark its
/// place and proportions and the blob shape gives it skin-like character —
/// a hard rectangle on a face read as a debug overlay, not a finding.
struct ConditionZoneOverlay: View {
    /// Regions in full-frame normalized coordinates (0-1, top-left origin).
    let regions: [CGRect]
    /// The photo's size — only the aspect matters to the fill mapping.
    let imageSize: CGSize
    /// The condition's 0-100 severity; deepens the marks.
    let score: Double

    var body: some View {
        GeometryReader { geo in
            let mapped = viewRects(in: geo.size)
            let fillOpacity = 0.55 + 0.30 * (min(max(score, 0), 100) / 100)

            ForEach(Array(mapped.enumerated()), id: \.offset) { index, rect in
                OrganicBlobShape(seed: seed(for: regions[index]))
                    .fill(Color.brandPrimary)
                    // Slightly larger than the box, and never so small that
                    // the soft edge swallows the whole mark.
                    .frame(width: max(rect.width * 1.25, 16),
                           height: max(rect.height * 1.25, 12))
                    .position(x: rect.midX, y: rect.midY)
                    .blur(radius: 2.5)
                    .opacity(fillOpacity)
            }
        }
        // The photo underneath stays the tap target; the drawing is inert.
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Stable per region: the same finding always wears the same shape.
    private func seed(for region: CGRect) -> UInt64 {
        Double(region.origin.x).bitPattern
            ^ (Double(region.origin.y).bitPattern &* 31)
            ^ (Double(region.width).bitPattern &* 131)
            ^ (Double(region.height).bitPattern &* 1021)
    }

    private func viewRects(in container: CGSize) -> [CGRect] {
        let transform = AspectFillMapper.transform(imageSize: imageSize, containerSize: container)
        return regions.map { region in
            CGRect(
                x: region.origin.x * imageSize.width,
                y: region.origin.y * imageSize.height,
                width: region.width * imageSize.width,
                height: region.height * imageSize.height
            )
            .applying(transform)
        }
    }
}

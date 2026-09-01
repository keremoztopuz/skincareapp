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

/// The selected condition's regions drawn over the scanned photo: each
/// rectangle gets a solid brand outline and a translucent brand fill whose
/// depth follows the severity — the same "how much" language as the bars.
/// Flat color only; no gradients.
struct ConditionZoneOverlay: View {
    /// Regions in full-frame normalized coordinates (0-1, top-left origin).
    let regions: [CGRect]
    /// The photo's size — only the aspect matters to the fill mapping.
    let imageSize: CGSize
    /// The condition's 0-100 severity; deepens the fill.
    let score: Double

    var body: some View {
        GeometryReader { geo in
            let mapped = viewRects(in: geo.size)
            let fillOpacity = 0.15 + 0.30 * (min(max(score, 0), 100) / 100)

            ForEach(Array(mapped.enumerated()), id: \.offset) { _, rect in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.brandPrimary.opacity(fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.brandPrimary, lineWidth: 2.5)
                    )
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        // The photo underneath stays the tap target; the drawing is inert.
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

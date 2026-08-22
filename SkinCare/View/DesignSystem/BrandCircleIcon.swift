//
//  BrandCircleIcon.swift
//  SkinCare
//

import SwiftUI

/// Signature nested-circle mark: blush outer ring, burgundy core, white glyph.
/// `animated` adds the breathing pulse: reserve it for splash and onboarding.
struct BrandCircleIcon: View {
    var systemImage: String? = nil
    var assetImage: String? = nil
    var size: CGFloat = 160
    var animated: Bool = false

    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.brandBlush)
                .frame(width: size, height: size)
                .scaleEffect(animated && isPulsing ? 1.12 : 1.0)
                .animation(
                    animated ? .easeInOut(duration: 1.4).repeatForever(autoreverses: true) : nil,
                    value: isPulsing
                )

            Circle()
                .fill(Color.brandPrimary)
                .frame(width: size * 0.72, height: size * 0.72)

            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.25))
                    .foregroundColor(.white)
            } else if let assetImage {
                Image(assetImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5, height: size * 0.5)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            if animated { isPulsing = true }
        }
        .accessibilityHidden(true)
    }
}

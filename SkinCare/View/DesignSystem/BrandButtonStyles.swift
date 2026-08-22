//
//  BrandButtonStyles.swift
//  SkinCare
//

import SwiftUI

/// Full-width burgundy CTA used on every screen's primary action.
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.brandPrimary.opacity(isEnabled ? 1.0 : 0.4))
            .cornerRadius(Radius.card)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Quieter blush-on-burgundy variant for secondary actions.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.brandBlush)
            .cornerRadius(Radius.card)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

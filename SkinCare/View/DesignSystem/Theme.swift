//
//  Theme.swift
//  SkinCare
//

import SwiftUI

extension Color {
    /// Burgundy brand color: buttons, accents, icons.
    static let brandPrimary = Color(red: 0.47, green: 0.11, blue: 0.17)
    /// Very light pink app background.
    static let brandBackground = Color(red: 1.0, green: 0.97, blue: 0.97)
    /// Soft pink: icon backgrounds, badges, skeletons.
    static let brandBlush = Color(red: 1.0, green: 0.87, blue: 0.87)
    /// Near-black primary text.
    static let brandText = Color(red: 0.1, green: 0.1, blue: 0.2)
    /// Positive score change.
    static let brandPositive = Color(red: 0.1, green: 0.6, blue: 0.3)
    /// Negative score change.
    static let brandNegative = Color(red: 0.8, green: 0.1, blue: 0.1)
}

enum Radius {
    /// Cards, buttons, sheets: the app-wide corner radius.
    static let card: CGFloat = 16
    /// Badges, thumbnails, small inline elements.
    static let small: CGFloat = 8
}

extension View {
    /// The single card shadow used across the app.
    func cardShadow() -> some View {
        shadow(color: Color.brandPrimary.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

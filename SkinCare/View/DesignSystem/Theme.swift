//
//  Theme.swift
//  SkinCare
//

import SwiftUI
import UIKit

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
    /// The single card shadow used across the app: a tight key shadow for
    /// edge definition layered under a soft ambient one for depth.
    func cardShadow() -> some View {
        self
            .shadow(color: Color.brandPrimary.opacity(0.06), radius: 2, x: 0, y: 1)
            .shadow(color: Color.brandPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

extension Font {
    /// System font that scales with Dynamic Type.
    /// Anchors the given design size to the closest text style so the
    /// existing fixed-size design scales proportionally with the user's
    /// text size setting. Drop-in replacement for `.system(size:weight:)`.
    static func scaled(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let style: UIFont.TextStyle
        switch size {
        case ..<12: style = .caption2
        case ..<13: style = .caption1
        case ..<15: style = .footnote
        case ..<16: style = .subheadline
        case ..<17: style = .callout
        case ..<18: style = .body
        case ..<21: style = .title3
        case ..<25: style = .title2
        case ..<31: style = .title1
        default: style = .largeTitle
        }
        let scaledSize = UIFontMetrics(forTextStyle: style).scaledValue(for: size)
        return .system(size: scaledSize, weight: weight)
    }
}

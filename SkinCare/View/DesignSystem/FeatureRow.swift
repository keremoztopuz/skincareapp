//
//  FeatureRow.swift
//  SkinCare
//

import SwiftUI

/// Plain feature row: small blush icon tile plus concrete copy.
/// Used on paywalls and plan summaries instead of checkmark lists.
struct FeatureRow: View {
    let icon: String
    let text: String
    var textColor: Color = .brandText
    var iconColor: Color = .brandPrimary
    var iconBackground: Color = .brandBlush

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.scaled(size: 15, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconBackground)
                .cornerRadius(Radius.small)
            Text(text)
                .font(.scaled(size: 15))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

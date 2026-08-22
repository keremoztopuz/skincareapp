//
//  ScoreBar.swift
//  SkinCare
//

import SwiftUI

/// Labeled horizontal score bar (0–100) used on record cards and result screens.
struct ScoreBar: View {
    let label: String
    let value: Double
    var tint: Color = .brandPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(value))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.brandText)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(tint.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(tint)
                        .frame(width: geo.size.width * (min(max(value, 0), 100) / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(label): \(Int(value))%"))
    }
}

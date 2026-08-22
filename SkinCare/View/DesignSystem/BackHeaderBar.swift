//
//  BackHeaderBar.swift
//  SkinCare
//

import SwiftUI

/// Custom navigation header: circular back button, centered title.
struct BackHeaderBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .accessibilityLabel(Text(NSLocalizedString("back", comment: "")))
            Spacer()
            Text(title)
                .font(.scaled(size: 18, weight: .bold))
                .foregroundColor(.brandText)
            Spacer()
            Circle().fill(Color.clear).frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

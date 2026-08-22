//
//  LegalLinks.swift
//  SkinCare
//

import SwiftUI

/// Public URLs for the app's legal documents.
/// Replace the placeholders with the published pages before App Store submission.
enum LegalURLs {
    static let terms = URL(string: "https://keremoztopuz.github.io/skincare-legal/terms")!
    static let privacy = URL(string: "https://keremoztopuz.github.io/skincare-legal/privacy")!
}

/// Terms of Use and Privacy Policy links required on every purchase screen
/// (App Store Review Guideline 3.1.2).
struct LegalFooter: View {
    var body: some View {
        HStack(spacing: 6) {
            Link(NSLocalizedString("terms_of_use", comment: ""), destination: LegalURLs.terms)
            Text("·")
            Link(NSLocalizedString("privacy_policy", comment: ""), destination: LegalURLs.privacy)
        }
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
}

import SwiftUI

struct AIConsentView: View {
    @Environment(\.dismiss) private var dismiss
    let onAccept: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "hand.raised.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.brandPrimary)
                    Text("ai_consent_title").font(.title2.bold())
                    Text("ai_consent_body")
                    Text("ai_consent_storage").foregroundStyle(.secondary)
                    LegalFooter()
                    Button("ai_consent_accept") {
                        UserDefaults.standard.set(true, forKey: AIAnalysisConsent.key)
                        onAccept()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("ai_consent_decline", role: .cancel) { dismiss() }
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(24)
            }
            .background(Color.brandBackground)
        }
    }
}

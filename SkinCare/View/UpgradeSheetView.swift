import SwiftUI
import RevenueCat

struct UpgradeSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = SubscriptionManager.shared
    @State private var isPurchasing = false
    @State private var showSuccess = false

    let mainColor      = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let outerColor     = Color(red: 1.0,  green: 0.87, blue: 0.87)
    let primaryText    = Color(red: 0.1,  green: 0.1,  blue: 0.2)

    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 24)

                // MARK: Icon
                ZStack {
                    Circle()
                        .fill(outerColor)
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(secondaryColor)
                        .frame(width: 76, height: 76)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)

                // MARK: Title
                VStack(spacing: 8) {
                    Text("Upgrade to Pro")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(primaryText)
                    Text("Unlock full skin analysis capabilities")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // MARK: Feature list
                VStack(spacing: 0) {
                    featureRow(icon: "infinity",             text: "Unlimited monthly scans",                 isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "waveform.path.ecg",   text: "Full analysis: Psoriasis, Wrinkles, Eye Bags", isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "clock.arrow.circlepath", text: "Full history — all past scans",         isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "sparkles",             text: "Unlimited AI product recommendations",   isFree: false)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Free tier reminder
                VStack(spacing: 0) {
                    featureRow(icon: "checkmark.circle", text: "5 scans / month",              isFree: true)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "checkmark.circle", text: "Acne & Eczema only",            isFree: true)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "checkmark.circle", text: "Last 5 analyses visible",       isFree: true)
                }
                .background(Color.white.opacity(0.6))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, 20)

                Spacer()

                // MARK: Price badge
                Text("$9.99 / month  ·  Cancel anytime")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.bottom, 12)

                // MARK: Buy button
                Button {
                    purchase()
                } label: {
                    HStack(spacing: 10) {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 17))
                            Text("Upgrade Now")
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(secondaryColor)
                    .cornerRadius(16)
                    .shadow(color: secondaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 20)

                // MARK: Continue free
                Button {
                    dismiss()
                } label: {
                    Text("Continue with Free Plan")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.vertical, 14)
                }

                Color.clear.frame(height: 8)
            }
        }
        .overlay {
            if showSuccess {
                successOverlay
            }
        }
    }

    // MARK: - Feature Row
    private func featureRow(icon: String, text: String, isFree: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isFree ? Color.gray.opacity(0.5) : secondaryColor)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14, weight: isFree ? .regular : .medium))
                .foregroundColor(isFree ? .gray : primaryText)
            Spacer()
            if !isFree {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(secondaryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Success overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.white).frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(Color(red: 0.1, green: 0.6, blue: 0.3))
                }
                Text("Welcome to Pro!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("All features are now unlocked.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Purchase logic
    private func purchase() {
        isPurchasing = true
        
        Purchases.shared.getOfferings { offerings, error in
            if let package = offerings?.current?.monthly {
                Purchases.shared.purchase(package: package) { transaction, info, error, userCancelled in
                    DispatchQueue.main.async {
                        if info?.entitlements["pro"]?.isActive == true {
                            SubscriptionManager.shared.isPremium = true
                            isPurchasing = false
                            withAnimation { showSuccess = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                dismiss()
                            }
                        } else {
                            isPurchasing = false
                        }
                    }
                }
            } else {
                isPurchasing = false
            }
        }
    }
}

#Preview {
    UpgradeSheetView()
}

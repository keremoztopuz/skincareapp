import SwiftUI
import RevenueCat

struct UpgradeSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = SubscriptionManager.shared
    @State private var isPurchasing = false
    @State private var showSuccess = false
    @State private var purchaseError: String?
    @State private var priceText: String?

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            // Scrolls only when the content is taller than the sheet, so the
            // tail (restore / continue free / legal) stays reachable on short
            // screens without changing how it feels on tall ones.
            GeometryReader { proxy in
            ScrollView {
            VStack(spacing: 0) {

                // MARK: Drag handle
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 24)

                // MARK: Icon
                BrandCircleIcon(systemImage: "crown.fill", size: 110)
                    .padding(.bottom, 20)

                // MARK: Title
                VStack(spacing: 8) {
                    Text(NSLocalizedString("upgrade_to_pro", comment: ""))
                        .font(.scaled(size: 28, weight: .bold))
                        .foregroundColor(.brandText)
                    Text(NSLocalizedString("unlock_full_capabilities", comment: ""))
                        .font(.scaled(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // MARK: Feature list
                VStack(spacing: 0) {
                    featureRow(icon: "infinity", text: NSLocalizedString("upgrade_feature_unlimited_scans", comment: ""), isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "waveform.path.ecg", text: NSLocalizedString("upgrade_feature_full_analysis", comment: ""), isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "clock.arrow.circlepath", text: NSLocalizedString("upgrade_feature_full_history", comment: ""), isFree: false)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "bag.fill", text: NSLocalizedString("upgrade_feature_unlimited_recommendations", comment: ""), isFree: false)
                }
                .background(Color.white)
                .cornerRadius(Radius.card)
                .cardShadow()
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: Free tier reminder
                VStack(spacing: 0) {
                    featureRow(icon: "camera.viewfinder", text: NSLocalizedString("free_feature_5_scans", comment: ""), isFree: true)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "face.dashed", text: NSLocalizedString("free_feature_conditions", comment: ""), isFree: true)
                    Divider().padding(.horizontal, 20)
                    featureRow(icon: "clock", text: NSLocalizedString("free_feature_last_5", comment: ""), isFree: true)
                }
                .background(Color.white.opacity(0.6))
                .cornerRadius(Radius.card)
                .overlay(RoundedRectangle(cornerRadius: Radius.card).stroke(Color.gray.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, 20)

                Spacer()

                // MARK: Price and renewal disclosure
                if let price = priceText {
                    Text(String(format: NSLocalizedString("price_monthly_%@", comment: ""), price))
                        .font(.scaled(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }

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
                                .font(.scaled(size: 17))
                            Text(NSLocalizedString("upgrade_now", comment: ""))
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isPurchasing)
                .padding(.horizontal, 20)

                // MARK: Restore + continue free
                Button {
                    restore()
                } label: {
                    Text(NSLocalizedString("restore_purchases", comment: ""))
                        .font(.scaled(size: 13, weight: .medium))
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(.top, 12)
                }
                .disabled(isPurchasing)

                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("continue_with_free_plan", comment: ""))
                        .font(.scaled(size: 15))
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                }

                LegalFooter()

                Color.clear.frame(height: 8)
            }
            .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            }
        }
        .presentationDetents([.large])
        .onAppear { loadPrice() }
        .alert(AppStrings.purchaseError, isPresented: Binding(
            get: { purchaseError != nil },
            set: { if !$0 { purchaseError = nil } }
        )) {
            Button(AppStrings.ok, role: .cancel) {}
        } message: {
            Text(purchaseError ?? "")
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
                .font(.scaled(size: 16))
                .foregroundColor(isFree ? Color.gray.opacity(0.5) : .brandPrimary)
                .frame(width: 22)
            Text(text)
                .font(.scaled(size: 14, weight: isFree ? .regular : .medium))
                .foregroundColor(isFree ? .gray : .brandText)
            Spacer()
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
                        .font(.scaled(size: 52))
                        .foregroundColor(.brandPrimary)
                }
                Text(NSLocalizedString("welcome_to_pro", comment: ""))
                    .font(.scaled(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(NSLocalizedString("all_features_now_unlocked", comment: ""))
                    .font(.scaled(size: 15))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Localized price
    private func loadPrice() {
        Purchases.shared.getOfferings { offerings, _ in
            guard let package = offerings?.current?.monthly ?? offerings?.current?.availablePackages.first else { return }
            DispatchQueue.main.async {
                priceText = package.storeProduct.localizedPriceString
            }
        }
    }

    // MARK: - Purchase logic
    private func purchase() {
        isPurchasing = true
        purchaseError = nil

        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                DispatchQueue.main.async {
                    isPurchasing = false
                    purchaseError = String(format: NSLocalizedString("purchase_error_products_not_loaded_%@", comment: ""), error.localizedDescription)
                }
                return
            }

            guard let package = offerings?.current?.monthly ?? offerings?.current?.availablePackages.first else {
                DispatchQueue.main.async {
                    isPurchasing = false
                    purchaseError = NSLocalizedString("purchase_error_package_not_found", comment: "")
                }
                return
            }

            Purchases.shared.purchase(package: package) { transaction, info, error, userCancelled in
                DispatchQueue.main.async {
                    isPurchasing = false
                    if userCancelled { return }
                    if let error = error {
                        purchaseError = String(format: NSLocalizedString("purchase_error_failed_%@", comment: ""), error.localizedDescription)
                        return
                    }

                    let entitled = info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true
                    if entitled || transaction != nil {
                        SubscriptionManager.shared.isPremium = true
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func restore() {
        isPurchasing = true
        purchaseError = nil
        Purchases.shared.restorePurchases { info, error in
            DispatchQueue.main.async {
                isPurchasing = false
                if let error = error {
                    purchaseError = String(format: NSLocalizedString("purchase_error_restore_failed_%@", comment: ""), error.localizedDescription)
                    return
                }
                if info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true {
                    SubscriptionManager.shared.isPremium = true
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UpgradeSheetView()
}

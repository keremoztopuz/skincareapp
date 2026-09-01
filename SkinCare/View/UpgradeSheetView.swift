import SwiftUI
import RevenueCat

/// Where the paywall is being shown from. It is the same screen everywhere —
/// only its headline, its sheet chrome, and what leaving it means change.
enum PaywallContext {
    /// The onboarding step. Not a sheet: there is nothing to dismiss back to,
    /// so this one advances the app flow itself via `onFlowStep`.
    case onboarding
    /// A sheet from Settings or one of the locked Pro surfaces.
    case upgrade
    /// A sheet thrown when the free monthly scan quota is spent.
    case scanLimit
}

struct UpgradeSheetView: View {
    var context: PaywallContext = .upgrade

    /// Set only by the onboarding step, which owns a flow transition instead
    /// of a dismissal. `true` when the user bought or restored Pro.
    /// A closure rather than an `@EnvironmentObject` so the five sheet call
    /// sites cannot crash on a missing environment value.
    var onFlowStep: ((Bool) -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    @State private var showSuccess = false
    @State private var purchaseError: String?
    @State private var priceText: String = SubscriptionManager.FallbackPrice.weekly
    @State private var lifetimePriceText: String = SubscriptionManager.FallbackPrice.lifetime
    @State private var trial: SubscriptionManager.TrialPeriod?
    @State private var selectedPlan: Plan = .weekly

    enum Plan {
        case weekly, lifetime
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            // Scrolls only when the content is taller than the sheet, so the
            // tail (restore / continue free / legal) stays reachable on short
            // screens without changing how it feels on tall ones.
            GeometryReader { proxy in
            // Short screens (iPhone SE) get a smaller crown and tighter
            // spacing so the plan picker stays above the fold.
            let isCompact = proxy.size.height < 700
            ScrollView {
            VStack(spacing: 0) {

                // MARK: Drag handle
                // Sheets only: as a flow step there is nothing to drag away.
                if isSheet {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                } else {
                    Color.clear.frame(height: 24)
                }

                // MARK: Icon
                BrandCircleIcon(systemImage: "crown.fill", size: isCompact ? 84 : 110)
                    .padding(.bottom, isCompact ? 12 : 20)

                // MARK: Title
                VStack(spacing: 8) {
                    Text(title)
                        .font(.scaled(size: isCompact ? 23 : 28, weight: .bold))
                        .foregroundColor(.brandText)
                        .multilineTextAlignment(.center)
                    Text(subtitle)
                        .font(.scaled(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, isCompact ? 18 : 28)

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

                Spacer()

                // MARK: Plan picker
                VStack(spacing: 10) {
                    planRow(
                        plan: .weekly,
                        title: AppStrings.pro,
                        price: priceText,
                        period: AppStrings.perWeek,
                        badgeKey: nil
                    )
                    planRow(
                        plan: .lifetime,
                        title: NSLocalizedString("lifetime_plan", comment: ""),
                        price: lifetimePriceText,
                        period: NSLocalizedString("one_time", comment: ""),
                        badgeKey: "best_value"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Price and renewal disclosure
                Text(disclosureText)
                    .font(.scaled(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                // MARK: Buy button
                Button {
                    purchase(plan: selectedPlan)
                } label: {
                    HStack(spacing: 10) {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "crown.fill")
                                .font(.scaled(size: 17))
                            Text(buyButtonTitle)
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
                    finish(isPremium: false)
                } label: {
                    Text(NSLocalizedString("continue_with_free", comment: ""))
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
        .presentationDetents(isSheet ? [.large] : [])
        .onAppear { loadPrices() }
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

    // MARK: - Context
    private var isSheet: Bool { context != .onboarding }

    private var title: String {
        switch context {
        case .scanLimit: return AppStrings.scanLimitReached
        case .onboarding, .upgrade: return NSLocalizedString("upgrade_to_pro", comment: "")
        }
    }

    private var subtitle: String {
        switch context {
        case .scanLimit:
            return String(
                format: NSLocalizedString("free_scans_used", comment: ""),
                SubscriptionManager.shared.freeMonthlyLimit
            )
        case .onboarding, .upgrade:
            return NSLocalizedString("unlock_full_capabilities", comment: "")
        }
    }

    /// The single exit point. A flow step hands control back to the app state
    /// machine; a sheet just closes. Calling `dismiss()` in the onboarding
    /// context would strand the user on a screen nothing presented.
    private func finish(isPremium: Bool) {
        if let onFlowStep {
            onFlowStep(isPremium)
        } else {
            dismiss()
        }
    }

    // MARK: - Plan copy
    /// Trial wording only appears when the App Store actually offers one.
    private var buyButtonTitle: String {
        switch selectedPlan {
        case .lifetime:
            return NSLocalizedString("get_lifetime_access", comment: "")
        case .weekly:
            if let trial {
                return trial.startCTA
            }
            return NSLocalizedString("upgrade_now", comment: "")
        }
    }

    private var disclosureText: String {
        switch selectedPlan {
        case .lifetime:
            return String(format: NSLocalizedString("one_time_price_%@", comment: ""), lifetimePriceText)
        case .weekly:
            let key = trial == nil ? "price_weekly_%@" : "then_price_weekly_%@"
            return String(format: NSLocalizedString(key, comment: ""), priceText)
        }
    }

    // MARK: - Plan Row
    private func planRow(plan: Plan, title: String, price: String, period: String, badgeKey: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.brandPrimary : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.scaled(size: 16, weight: .bold))
                            .foregroundColor(.brandText)

                        if let badgeKey {
                            Text(NSLocalizedString(badgeKey, comment: ""))
                                .font(.scaled(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.brandPrimary)
                                .cornerRadius(Radius.small)
                        }
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(price)
                            .font(.scaled(size: 17, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(period)
                            .font(.scaled(size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card)
                    .stroke(isSelected ? Color.brandPrimary : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
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

    // MARK: - Localized prices
    /// Prices come from StoreKit, so each storefront shows its own App Store
    /// Connect price and currency; the fallbacks only fill the gap until then.
    private func loadPrices() {
        guard Purchases.isConfigured else { return }
        Purchases.shared.getOfferings { offerings, _ in
            guard let current = offerings?.current else { return }
            // Only the true $rc_weekly package may feed the weekly row —
            // falling back to an arbitrary package could show the lifetime
            // price as if it were weekly.
            let weekly = current.weekly
            let lifetime = current.lifetime
            DispatchQueue.main.async {
                if let live = weekly?.storeProduct.localizedPriceString {
                    priceText = live
                }
                if let live = lifetime?.storeProduct.localizedPriceString {
                    lifetimePriceText = live
                }
                trial = weekly.flatMap { SubscriptionManager.trialPeriod(in: $0.storeProduct) }
            }
        }
    }

    // MARK: - Purchase logic
    private func purchase(plan: Plan) {
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

            let current = offerings?.current
            // Never substitute another package for weekly: an offering
            // without a weekly package must fail loudly, not charge lifetime.
            let selected: Package? = plan == .lifetime
                ? current?.lifetime
                : current?.weekly

            guard let package = selected else {
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

                    // Only the entitlement unlocks Pro. A non-nil transaction
                    // alone can be deferred (Ask to Buy) or not yet synced,
                    // and would be revoked on the next status check anyway.
                    let entitled = info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true
                    if entitled {
                        SubscriptionManager.shared.isPremium = true
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            finish(isPremium: true)
                        }
                    } else if transaction != nil {
                        purchaseError = NSLocalizedString("purchase_pending_message", comment: "")
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
                        finish(isPremium: true)
                    }
                } else {
                    purchaseError = NSLocalizedString("restore_no_subscription", comment: "")
                }
            }
        }
    }
}

#Preview("Sheet") {
    UpgradeSheetView()
}

#Preview("Scan limit") {
    UpgradeSheetView(context: .scanLimit)
}

#Preview("Onboarding") {
    UpgradeSheetView(context: .onboarding) { _ in }
}

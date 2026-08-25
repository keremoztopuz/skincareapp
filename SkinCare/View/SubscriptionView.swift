//
//  SubscriptionView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 24.04.2026.
//

import Foundation
import SwiftUI
import RevenueCat

struct SubscriptionView: View {
    @State private var logoScale: CGFloat = 0
    @State private var selectedPlan: Plan = .pro
    @State private var freeCardAppeared = false
    @State private var proCardAppeared = false
    @State private var lifetimeCardAppeared = false
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State private var proPriceText: String = SubscriptionManager.FallbackPrice.monthly
    @State private var lifetimePriceText: String = SubscriptionManager.FallbackPrice.lifetime
    @State private var trial: SubscriptionManager.TrialPeriod?
    @EnvironmentObject var appVM: ContentViewModel

    enum Plan {
        case free, pro, lifetime
    }

    var body: some View {
        ZStack {
            // Outside the GeometryReader so the fill always reaches the
            // status bar, whatever the content height turns out to be.
            Color.brandBackground.ignoresSafeArea()

            // Scrolls only when the content is taller than the screen, so the
            // CTA, restore and legal footer stay reachable at large text
            // sizes and on short devices.
            GeometryReader { geo in
                let m = Metrics.fitting(height: geo.size.height)
                let outerSize = geo.size.width * m.logoRatio

                ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Logo
                    BrandCircleIcon(systemImage: "crown.fill", size: outerSize, animated: true)
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                logoScale = 1.0
                            }
                        }
                    .padding(.top, m.topPadding)

                    // MARK: - Title
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("unlock_premium", comment: ""))
                                .font(.scaled(size: m.titleSize, weight: .bold))
                                .foregroundColor(.brandText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                        }
                    .padding(.top, 6)

                    // MARK: - Plan Cards
                    VStack(spacing: m.cardSpacing) {
                            planCard(
                                plan: .free,
                                title: AppStrings.free,
                                price: "",
                                period: "",
                                features: [
                                    ("camera.viewfinder", NSLocalizedString("5_analysis_per_month", comment: "")),
                                    ("chart.bar", NSLocalizedString("basic_insights", comment: ""))
                                ],
                                style: .plain,
                                metrics: m
                            )
                            .scaleEffect(freeCardAppeared ? 1.0 : 0.8)
                            .opacity(freeCardAppeared ? 1.0 : 0)

                            planCard(
                                plan: .pro,
                                title: AppStrings.pro,
                                price: proPriceText,
                                period: AppStrings.perMonth,
                                features: [
                                    ("infinity", NSLocalizedString("unlimited_analysis", comment: "")),
                                    ("bag.fill", NSLocalizedString("full_recommendations", comment: ""))
                                ],
                                style: .featured,
                                metrics: m
                            )
                            .scaleEffect(proCardAppeared ? 1.0 : 0.8)
                            .opacity(proCardAppeared ? 1.0 : 0)

                            planCard(
                                plan: .lifetime,
                                title: NSLocalizedString("lifetime_plan", comment: ""),
                                price: lifetimePriceText,
                                period: NSLocalizedString("one_time", comment: ""),
                                features: [
                                    ("crown.fill", NSLocalizedString("everything_in_pro", comment: "")),
                                    ("checkmark.seal.fill", NSLocalizedString("pay_once_use_forever", comment: ""))
                                ],
                                style: .accented,
                                metrics: m
                            )
                            .scaleEffect(lifetimeCardAppeared ? 1.0 : 0.8)
                            .opacity(lifetimeCardAppeared ? 1.0 : 0)
                        }
                    .padding(.horizontal, 20)
                    .padding(.top, m.cardsTopPadding)
                    .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.15)) {
                                freeCardAppeared = true
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.29)) {
                                proCardAppeared = true
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.43)) {
                                lifetimeCardAppeared = true
                            }
                    }

                    Spacer(minLength: 4)

                    // MARK: - CTA Button
                    VStack(spacing: m.ctaSpacing) {
                            Button(action: {
                                switch selectedPlan {
                                case .pro:
                                    purchase(plan: .pro)
                                case .lifetime:
                                    purchase(plan: .lifetime)
                                case .free:
                                    appVM.completePurchaseStep(isPremium: false)
                                }
                            }) {
                                VStack(spacing: 3) {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.vertical, 6)
                                    } else {
                                        Text(ctaTitle)
                                            .font(.scaled(size: 18, weight: .bold))

                                        if let caption = ctaCaption {
                                            Text(caption)
                                                .font(.scaled(size: 12, weight: .regular))
                                                .opacity(0.85)
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, m.ctaVerticalPadding)
                                .background(Color.brandPrimary)
                                .cornerRadius(Radius.card)
                            }
                            .disabled(isPurchasing)

                            if selectedPlan != .free {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPlan = .free
                                    }
                                }) {
                                    Text(NSLocalizedString("no_thanks_free", comment: ""))
                                        .font(.scaled(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }

                            Button(action: {
                                restorePurchases()
                            }) {
                                Text(NSLocalizedString("restore_purchases", comment: ""))
                                    .font(.scaled(size: 13, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.7))
                            }

                            LegalFooter()
                        }
                    .padding(.horizontal, 20)
                    .padding(.bottom, m.bottomPadding)
                }
                .frame(minHeight: geo.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .onAppear { loadPrices() }
        .alert(AppStrings.purchaseError, isPresented: Binding(
            get: { purchaseError != nil },
            set: { if !$0 { purchaseError = nil } }
        )) {
            Button(AppStrings.ok, role: .cancel) {}
        } message: {
            Text(purchaseError ?? "")
        }
    }

    // MARK: - Adaptive metrics
    /// The layout tightens on short screens so scrolling stays the exception.
    /// Two steps are enough: the roomy default, and a compact set for short
    /// screens (iPhone SE and anything else under ~700pt of usable height).
    private struct Metrics {
        let logoRatio: CGFloat
        let titleSize: CGFloat
        let topPadding: CGFloat
        let cardSpacing: CGFloat
        let cardPadding: CGFloat
        let cardsTopPadding: CGFloat
        let featureSpacing: CGFloat
        let ctaSpacing: CGFloat
        let ctaVerticalPadding: CGFloat
        let bottomPadding: CGFloat

        static func fitting(height: CGFloat) -> Metrics {
            if height < 700 {
                return Metrics(
                    logoRatio: 0.13, titleSize: 20, topPadding: 2,
                    cardSpacing: 6, cardPadding: 10, cardsTopPadding: 6,
                    featureSpacing: 6, ctaSpacing: 4, ctaVerticalPadding: 12,
                    bottomPadding: 6
                )
            }
            return Metrics(
                logoRatio: 0.16, titleSize: 22, topPadding: 8,
                cardSpacing: 8, cardPadding: 12, cardsTopPadding: 10,
                featureSpacing: 8, ctaSpacing: 8, ctaVerticalPadding: 15,
                bottomPadding: 12
            )
        }
    }

    // MARK: - CTA copy
    /// Trial wording only appears when the App Store actually offers one, so
    /// the button can never promise a trial the subscription does not carry.
    private var ctaTitle: String {
        switch selectedPlan {
        case .pro:
            if let trial {
                return trial.startCTA
            }
            return NSLocalizedString("get_pro", comment: "")
        case .lifetime: return NSLocalizedString("get_lifetime_access", comment: "")
        case .free: return NSLocalizedString("continue_with_free", comment: "")
        }
    }

    private var ctaCaption: String? {
        switch selectedPlan {
        case .pro:
            if trial != nil {
                return String(format: NSLocalizedString("then_price_monthly_%@", comment: ""), proPriceText)
            }
            return String(format: NSLocalizedString("price_monthly_%@", comment: ""), proPriceText)
        case .lifetime:
            return String(format: NSLocalizedString("one_time_price_%@", comment: ""), lifetimePriceText)
        case .free:
            return nil
        }
    }


    // MARK: - Card style
    /// `featured` is the filled burgundy card (Pro); `accented` keeps the white
    /// body but carries the burgundy border and badge (Lifetime).
    private enum CardStyle {
        case plain, featured, accented

        var isFilled: Bool { self == .featured }

        var badgeKey: String? {
            switch self {
            case .featured: return "popular"
            case .accented: return "best_value"
            case .plain: return nil
            }
        }
    }

    // MARK: - Plan Card
    private func planCard(plan: Plan, title: String, price: String, period: String, features: [(String, String)], style: CardStyle, metrics m: Metrics) -> some View {
        let isSelected = selectedPlan == plan
        let isFilled = style.isFilled

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(.scaled(size: 20, weight: .bold))
                                .foregroundColor(isFilled ? .white : .brandText)

                            if let badgeKey = style.badgeKey {
                                Text(NSLocalizedString(badgeKey, comment: ""))
                                    .font(.scaled(size: 10, weight: .bold))
                                    .foregroundColor(isFilled ? .brandPrimarySoft : .white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(isFilled ? Color.white : Color.brandPrimary)
                                    .cornerRadius(Radius.small)
                            }
                        }

                        // The free plan has no price to state; its title
                        // already says so, and repeating it read as a bug.
                        if !price.isEmpty {
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(price)
                                    .font(.scaled(size: 22, weight: .bold))
                                    .foregroundColor(isFilled ? .white : .brandPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text(period)
                                    .font(.scaled(size: 14, weight: .regular))
                                    .foregroundColor(isFilled ? .white.opacity(0.7) : .gray)
                            }
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(isFilled ? .white : (isSelected ? Color.brandPrimary : Color.gray.opacity(0.3)), lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(isFilled ? .white : Color.brandPrimary)
                                .frame(width: 14, height: 14)
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 2)

                VStack(spacing: m.featureSpacing) {
                    ForEach(features, id: \.1) { icon, text in
                        HStack(spacing: 10) {
                            Image(systemName: icon)
                                .font(.scaled(size: 13))
                                .foregroundColor(isFilled ? .white.opacity(0.9) : .brandPrimary)
                                .frame(width: 20)

                            Text(text)
                                .font(.scaled(size: 13, weight: .regular))
                                .foregroundColor(isFilled ? .white.opacity(0.9) : .brandText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            Spacer()
                        }
                    }
                }
            }
            .padding(m.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .fill(isFilled ? Color.brandPrimarySoft : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card)
                    .stroke(borderColor(style: style, isSelected: isSelected), lineWidth: isSelected ? 2 : 1)
            )
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func borderColor(style: CardStyle, isSelected: Bool) -> Color {
        switch style {
        case .featured:
            return .clear
        case .accented:
            return isSelected ? Color.brandPrimary : Color.brandPrimary.opacity(0.35)
        case .plain:
            return isSelected ? Color.brandPrimary : Color.gray.opacity(0.15)
        }
    }

    // MARK: - Localized Prices
    /// Live storefront prices replace the FallbackPrice placeholders as soon
    /// as the offerings load; the fallbacks only fill the gap until then.
    /// Only the true `$rc_monthly` package may feed the Pro card — falling
    /// back to an arbitrary package could show (and charge) the lifetime
    /// price as if it were monthly.
    private func loadPrices() {
        guard Purchases.isConfigured else { return }
        Purchases.shared.getOfferings { offerings, _ in
            guard let current = offerings?.current else { return }
            let monthly = current.monthly
            let lifetime = current.lifetime
            DispatchQueue.main.async {
                if let live = monthly?.storeProduct.localizedPriceString {
                    proPriceText = live
                }
                if let live = lifetime?.storeProduct.localizedPriceString {
                    lifetimePriceText = live
                }
                trial = monthly.flatMap { SubscriptionManager.trialPeriod(in: $0.storeProduct) }
            }
        }
    }

    // MARK: - RevenueCat Purchase
    private func purchase(plan: Plan) {
        guard plan != .free else { return }
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
            let package: Package?
            switch plan {
            case .lifetime:
                package = current?.lifetime
            case .pro:
                // Never substitute another package: an offering without a
                // monthly package must fail loudly, not charge lifetime.
                package = current?.monthly
            case .free:
                package = nil
            }

            guard let package = package else {
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
                        appVM.completePurchaseStep(isPremium: true)
                    } else if transaction != nil {
                        purchaseError = NSLocalizedString("purchase_pending_message", comment: "")
                    }
                }
            }
        }
    }

    private func restorePurchases() {
        isPurchasing = true
        Purchases.shared.restorePurchases { info, error in
            DispatchQueue.main.async {
                isPurchasing = false
                if let error = error {
                    purchaseError = String(format: NSLocalizedString("purchase_error_restore_failed_%@", comment: ""), error.localizedDescription)
                    return
                }
                if info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true {
                    SubscriptionManager.shared.isPremium = true
                    appVM.completePurchaseStep(isPremium: true)
                } else {
                    purchaseError = NSLocalizedString("restore_no_subscription", comment: "")
                }
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(ContentViewModel())
}

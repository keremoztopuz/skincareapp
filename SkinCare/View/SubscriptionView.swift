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
    @State private var proPriceText: String = FallbackPrice.monthly
    @State private var lifetimePriceText: String = FallbackPrice.lifetime
    @EnvironmentObject var appVM: ContentViewModel

    enum Plan {
        case free, pro, lifetime
    }

    /// Shown until StoreKit returns the storefront price (and if it never does).
    /// Keep these in step with the App Store Connect price tiers — the live
    /// price always wins once `loadPrices()` answers.
    private enum FallbackPrice {
        static var monthly: String { forCurrency(turkish: "₺199,99", usd: "$3.99", eur: "€4,99") }
        static var lifetime: String { forCurrency(turkish: "₺899", usd: "$17.99", eur: "€19,99") }

        private static func forCurrency(turkish: String, usd: String, eur: String) -> String {
            switch Locale.current.currency?.identifier {
            case "TRY": return turkish
            case "EUR": return eur
            default: return usd
            }
        }
    }

    var body: some View {
        ZStack {
            // Outside the GeometryReader so the fill always reaches the
            // status bar, whatever the content height turns out to be.
            Color.brandBackground.ignoresSafeArea()

            GeometryReader { geo in
                let m = Metrics.fitting(height: geo.size.height)
                let outerSize = geo.size.width * m.logoRatio

                VStack(spacing: 0) {

                    // MARK: - Logo
                    BrandCircleIcon(systemImage: "crown.fill", size: outerSize, animated: true)
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                logoScale = 1.0
                            }
                            loadPrices()
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
                                price: NSLocalizedString("price_free", comment: ""),
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
            }
        }
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
    /// The screen never scrolls, so the layout tightens instead. Two steps are
    /// enough: the roomy default, and a compact set for short screens
    /// (iPhone SE and anything else under ~700pt of usable height).
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
    private var ctaTitle: String {
        switch selectedPlan {
        case .pro: return NSLocalizedString("start_free_trial", comment: "")
        case .lifetime: return NSLocalizedString("get_lifetime_access", comment: "")
        case .free: return NSLocalizedString("continue_with_free", comment: "")
        }
    }

    private var ctaCaption: String? {
        switch selectedPlan {
        case .pro:
            return String(format: NSLocalizedString("then_price_monthly_%@", comment: ""), proPriceText)
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
    /// Prices come from StoreKit, so each storefront shows its own App Store
    /// Connect price and currency; nothing is hardcoded here.
    private func loadPrices() {
        Purchases.shared.getOfferings { offerings, _ in
            guard let current = offerings?.current else { return }
            let monthly = current.monthly ?? current.availablePackages.first
            let lifetime = current.lifetime
            DispatchQueue.main.async {
                if let live = monthly?.storeProduct.localizedPriceString {
                    proPriceText = live
                }
                if let live = lifetime?.storeProduct.localizedPriceString {
                    lifetimePriceText = live
                }
            }
        }
    }

    // MARK: - RevenueCat Purchase
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
            let package: Package?
            switch plan {
            case .lifetime:
                package = current?.lifetime
            default:
                package = current?.monthly ?? current?.availablePackages.first
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

                    let entitled = info?.entitlements[SubscriptionManager.proEntitlementID]?.isActive == true
                    if entitled || transaction != nil {
                        SubscriptionManager.shared.isPremium = true
                        appVM.completePurchaseStep(isPremium: true)
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
                }
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(ContentViewModel())
}

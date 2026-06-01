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
    @State private var isPulsing = false
    @State private var selectedPlan: Plan = .pro
    @State private var freeCardAppeared = false
    @State private var proCardAppeared = false
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @StateObject private var vm = SubscriptionViewModel()
    @EnvironmentObject var appVM: ContentViewModel

    enum Plan {
        case free, pro
    }

    let mainColor = Color(red: 1.0, green: 0.97, blue: 0.97)
    let secondaryColor = Color(red: 0.47, green: 0.11, blue: 0.17)
    let outerColor = Color(red: 1.0, green: 0.87, blue: 0.87)

    var body: some View {
        GeometryReader { geo in
            let outerSize = geo.size.width * 0.28
            let innerSize = outerSize * 0.75

            ZStack {
                mainColor.ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Logo
                    ZStack {
                            Circle()
                                .fill(outerColor)
                                .frame(width: outerSize, height: outerSize)
                                .scaleEffect(isPulsing ? 1.12 : 1.0)
                                .animation(
                                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                    value: isPulsing
                                )

                            Circle()
                                .fill(secondaryColor)
                                .frame(width: innerSize, height: innerSize)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                logoScale = 1.0
                            }
                            isPulsing = true
                        }
                    .padding(.top, 24)

                    // MARK: - Title
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("unlock_premium", comment: ""))
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                        }
                    .padding(.top, 6)

                    // MARK: - Plan Cards
                    VStack(spacing: 12) {
                            planCard(
                                plan: .free,
                                title: AppStrings.free,
                                price: "$0",
                                period: AppStrings.perMonth,
                                features: [
                                    ("sparkles", NSLocalizedString("5_analysis_per_month", comment: "")),
                                    ("face.smiling", NSLocalizedString("basic_insights", comment: "")),
                                    ("bag", NSLocalizedString("limited_recommendations", comment: "")),
                                    ("clock.arrow.circlepath", NSLocalizedString("last_5_scans", comment: ""))
                                ],
                                isPopular: false
                            )
                            .scaleEffect(freeCardAppeared ? 1.0 : 0.8)
                            .opacity(freeCardAppeared ? 1.0 : 0)

                            planCard(
                                plan: .pro,
                                title: AppStrings.pro,
                                price: "$4.99",
                                period: AppStrings.perMonth,
                                features: [
                                    ("infinity", NSLocalizedString("unlimited_analysis", comment: "")),
                                    ("face.smiling.inverse", NSLocalizedString("all_conditions_detected", comment: "")),
                                    ("bag.fill", NSLocalizedString("full_recommendations", comment: "")),
                                    ("chart.line.uptrend.xyaxis", NSLocalizedString("complete_history", comment: ""))
                                ],
                                isPopular: true
                            )
                            .scaleEffect(proCardAppeared ? 1.0 : 0.8)
                            .opacity(proCardAppeared ? 1.0 : 0)
                        }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.15)) {
                                freeCardAppeared = true
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                                proCardAppeared = true
                            }
                    }

                    Spacer()

                    // MARK: - CTA Button
                    VStack(spacing: 10) {
                            Button(action: {
                                if selectedPlan == .pro {
                                    purchasePro()
                                } else {
                                    appVM.completePurchaseStep(isPremium: false)
                                }
                            }) {
                                VStack(spacing: 3) {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.vertical, 6)
                                    } else {
                                        Text(selectedPlan == .pro ? NSLocalizedString("start_free_trial", comment: "") : NSLocalizedString("continue_with_free", comment: ""))
                                            .font(.system(size: 18, weight: .bold))

                                        if selectedPlan == .pro {
                                            Text(NSLocalizedString("then_price_monthly", comment: ""))
                                                .font(.system(size: 12, weight: .regular))
                                                .opacity(0.85)
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(secondaryColor)
                                .cornerRadius(16)
                            }
                            .disabled(isPurchasing)

                            if selectedPlan == .pro {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPlan = .free
                                    }
                                }) {
                                    Text(NSLocalizedString("no_thanks_free", comment: ""))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }

                            Button(action: {
                                restorePurchases()
                            }) {
                                Text(NSLocalizedString("restore_purchases", comment: ""))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                        }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
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
    }

    // MARK: - Plan Card
    func planCard(plan: Plan, title: String, price: String, period: String, features: [(String, String)], isPopular: Bool) -> some View {
        let isSelected = selectedPlan == plan

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPlan = plan
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(isPopular ? .white : Color(red: 0.1, green: 0.1, blue: 0.2))

                            if isPopular {
                                Text(NSLocalizedString("popular", comment: ""))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(secondaryColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.white)
                                    .cornerRadius(6)
                            }
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text(price)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(isPopular ? .white : secondaryColor)
                            Text(period)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(isPopular ? .white.opacity(0.7) : .gray)
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(isPopular ? .white : (isSelected ? secondaryColor : Color.gray.opacity(0.3)), lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(isPopular ? .white : secondaryColor)
                                .frame(width: 14, height: 14)
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 4)

                VStack(spacing: 10) {
                    ForEach(features, id: \.1) { icon, text in
                        HStack(spacing: 10) {
                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundColor(isPopular ? .white.opacity(0.9) : secondaryColor)
                                .frame(width: 20)

                            Text(text)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(isPopular ? .white.opacity(0.9) : Color(red: 0.1, green: 0.1, blue: 0.2))

                            Spacer()
                        }
                    }
                }

                if isPopular {
                    HStack {
                        Spacer()
                        Text(NSLocalizedString("free_trial_included", comment: ""))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPopular ? secondaryColor : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected && !isPopular ? secondaryColor : Color.gray.opacity(isPopular ? 0 : 0.15), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 12 : 6, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - RevenueCat Purchase
    private func purchasePro() {
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

                    let entitled = info?.entitlements["pro"]?.isActive == true
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
                if info?.entitlements["pro"]?.isActive == true {
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

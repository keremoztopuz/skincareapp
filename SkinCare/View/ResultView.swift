//
//  ResultView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: ResultsViewModel
    var onDismiss: (() -> Void)? = nil

    let record: AnalysisRecord?
    let isFromRecents: Bool
    @State private var showRecommendations = false
    @State private var selectedProduct: Product? = nil
    @State private var showProductDetail = false
    @State private var showUpgrade = false
    @State private var showRoutine = false
    @State private var routineCreated = false

    private var isPremium: Bool { SubscriptionManager.shared.isPremium }

    init(record: AnalysisRecord?, isFromRecents: Bool, onDismiss: (() -> Void)? = nil) {
        self.record = record
        self.isFromRecents = isFromRecents
        self.onDismiss = onDismiss
        self._vm = StateObject(wrappedValue: ResultsViewModel(record: record))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.brandBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Scanned Image Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text(NSLocalizedString("scanned_image", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.brandText)

                        ZStack {
                            if let data = record?.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                RoundedRectangle(cornerRadius: Radius.card)
                                    .fill(Color.brandPrimary.opacity(0.12))
                                    .overlay {
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color.brandPrimary.opacity(0.3))
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 370)
                        .cornerRadius(Radius.card)
                        .cardShadow()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isFromRecents ? 0 : 20)

                    // MARK: - Overall Score
                    if let record {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("overall_score", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brandText)

                            HStack {
                                Spacer()
                                ScoreRing(score: record.overallScore)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .background(Color.white)
                            .cornerRadius(Radius.card)
                            .cardShadow()
                        }
                        .padding(.horizontal, 20)
                    }

                    // MARK: - Results Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("results", comment: ""))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.brandText)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ResultBar(title: AppStrings.acne,    score: record?.acneScore   ?? 0, icon: "face.dashed")
                                ResultBar(title: AppStrings.redness, score: record?.eczemaScore ?? 0, icon: "drop.fill")
                                ResultBar(title: AppStrings.psoriasis, score: record?.psoriasisScore ?? 0, icon: "bandage.fill")
                                if isPremium {
                                    ResultBar(title: AppStrings.wrinkles,     score: record?.wrinkleScore      ?? 0, icon: "sun.max.fill")
                                    ResultBar(title: AppStrings.eyebags,      score: record?.eyebagScore       ?? 0, icon: "eye.fill")
                                    ResultBar(title: AppStrings.pigmentation, score: record?.pigmentationScore ?? 0, icon: "circle.hexagongrid")
                                    ResultBar(title: AppStrings.hydration,    score: record?.hydrationScore    ?? 0, icon: "drop.degreesign")
                                } else {
                                    Button { showUpgrade = true } label: { ResultBar(title: AppStrings.wrinkles, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                    Button { showUpgrade = true } label: { ResultBar(title: AppStrings.eyebags, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                    Button { showUpgrade = true } label: { ResultBar(title: AppStrings.pigmentation, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                    Button { showUpgrade = true } label: { ResultBar(title: AppStrings.hydration, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // MARK: - Recommended Products
                    if isFromRecents || showRecommendations {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("recommended_products", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.brandText)
                                .padding(.horizontal, 20)

                            if let error = vm.errorMessage, vm.recommendProduct.isEmpty, !vm.isLoading {
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    if vm.isLoading {
                                        ProgressView()
                                            .frame(width: 160, height: 160)
                                    } else {
                                        ForEach(isPremium ? vm.recommendProduct : Array(vm.recommendProduct.prefix(2))) { product in
                                            Button {
                                                selectedProduct = product
                                                showProductDetail = true
                                            } label: {
                                                ProductCard(product: product)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // MARK: - Action Buttons
                    if !isFromRecents && !showRecommendations {
                        Button(action: {
                            withAnimation { showRecommendations = true }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "bag.fill")
                                    .font(.system(size: 20))
                                Text(NSLocalizedString("see_recommendations", comment: ""))
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    } else if (isFromRecents || showRecommendations) && !vm.recommendProduct.isEmpty {
                        Button(action: {
                            createRoutineFromProducts()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: routineCreated ? "checkmark.circle.fill" : "calendar.badge.plus")
                                    .font(.system(size: 20))
                                Text(routineCreated ? AppStrings.routineCreated : AppStrings.createRoutine)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(routineCreated)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    } else {
                        Color.clear.frame(height: 20)
                    }

                    // MARK: - Non-diagnostic disclaimer
                    // Pad before expanding: the reverse order makes this text
                    // wider than the screen and shifts the whole page sideways.
                    Text(NSLocalizedString("results_not_medical_advice", comment: ""))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                }
                .padding(.top, 70)
            }

            Button(action: closeResult) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .accessibilityLabel(Text(NSLocalizedString("back", comment: "")))
            .padding(.leading, 20)
            .padding(.top, 10)
            .zIndex(10)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                NavigationStack {
                    DetailView(type: .product(product))
                }
            }
        }
        .fullScreenCover(isPresented: $showRoutine) {
            NavigationStack {
                RoutineView(selectedTab: .constant(0))
            }
        }
    }

    private func closeResult() {
        onDismiss?()
        dismiss()
    }

    private func createRoutineFromProducts() {
        let products = isPremium ? vm.recommendProduct : Array(vm.recommendProduct.prefix(2))
        let manager = LocalPersistenceManager.shared

        let stepMap: [String: (order: Int16, times: [String])] = [
            "cleanser":   (0, ["morning", "evening"]),
            "serum":      (1, ["morning"]),
            "treatment":  (1, ["evening"]),
            "eye_cream":  (2, ["evening"]),
            "eye_serum":  (2, ["evening"]),
            "moisturizer":(3, ["morning", "evening"]),
            "sunscreen":  (4, ["morning"])
        ]

        for product in products {
            guard let type = product.productType,
                  let mapping = stepMap[type] else { continue }

            for time in mapping.times {
                manager.saveRoutineItem(
                    productId: product.id,
                    productName: product.name,
                    productBrand: product.brand,
                    productImageUrl: product.imageUrl,
                    productType: type,
                    routineTime: time,
                    stepOrder: mapping.order,
                    isManuallyAdded: false
                )
            }
        }

        withAnimation {
            routineCreated = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showRoutine = true
        }
    }
}

// MARK: - ResultBar Struct
struct ResultBar: View {
    let title: String
    let score: Double
    let icon: String
    var locked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(locked ? Color.gray.opacity(0.15) : Color.brandPrimary)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(locked ? .gray.opacity(0.5) : .white)
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(locked ? .gray.opacity(0.5) : .brandText)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if locked {
                    Text(AppStrings.pro)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandBlush)
                        .cornerRadius(Radius.small)
                } else {
                    Text("\(Int(score))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.brandPrimary)

                    Text("/100")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    Spacer(minLength: 6)

                    Text(Severity(score: score).localizedTitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.brandBlush)
                        .cornerRadius(Radius.small)
                }
            }
            .frame(height: 34)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(locked ? Color.gray.opacity(0.12) : Color.brandPrimary.opacity(0.1))
                        .frame(height: 6)
                    if !locked {
                        RoundedRectangle(cornerRadius: Radius.small)
                            .fill(Color.brandPrimary)
                            .frame(width: geo.size.width * (score / 100), height: 6)
                    }
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .frame(width: 170)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }
}

#Preview {
    ResultView(record: nil, isFromRecents: true)
}

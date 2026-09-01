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
    @State private var selectedProduct: Product? = nil
    @State private var showUpgrade = false
    @State private var showRoutine = false
    @State private var routineCreated = false

    // Observed so the locked bars unlock the moment the user buys Pro in
    // the upgrade sheet this very screen presents.
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    private var isPremium: Bool { subscriptionManager.isPremium }

    /// The free tier sees the first two only. The list arrives ordered by
    /// condition weight, so those two answer the worst finding.
    private var visibleProducts: [Product] {
        isPremium ? vm.recommendProduct : Array(vm.recommendProduct.prefix(2))
    }

    private var hiddenProductCount: Int {
        vm.recommendProduct.count - visibleProducts.count
    }

    init(record: AnalysisRecord?, isFromRecents: Bool, onDismiss: (() -> Void)? = nil) {
        self.record = record
        self.isFromRecents = isFromRecents
        self.onDismiss = onDismiss
        self._vm = StateObject(wrappedValue: ResultsViewModel(record: record, isHistorical: isFromRecents))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.brandBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Scanned Image Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text(NSLocalizedString("scanned_image", comment: ""))
                            .font(.scaled(size: 18, weight: .bold))
                            .foregroundColor(.brandText)

                        // The photo is drawn as an overlay so a fill-scaled image
                        // can never widen the layout beyond the screen.
                        Rectangle()
                            .fill(Color.brandPrimary.opacity(0.12))
                            .frame(maxWidth: .infinity)
                            .frame(height: 370)
                            .overlay {
                                if let data = record?.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.scaled(size: 50))
                                        .foregroundColor(Color.brandPrimary.opacity(0.3))
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                            .cardShadow()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isFromRecents ? 0 : 20)

                    // MARK: - Overall Score
                    if let record {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(NSLocalizedString("overall_score", comment: ""))
                                .font(.scaled(size: 18, weight: .bold))
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
                        Text(AppStrings.results)
                            .font(.scaled(size: 18, weight: .bold))
                            .foregroundColor(.brandText)

                        // Stacked, not a horizontal scroller: all five
                        // measurements are the point of this screen, and the
                        // three past the fold were being missed entirely.
                        VStack(spacing: 16) {
                            ResultBar(title: AppStrings.acne,    score: record?.acneScore   ?? 0, icon: "face.dashed")
                            ResultBar(title: AppStrings.redness, score: record?.eczemaScore ?? 0, icon: "drop.fill")
                            if isPremium {
                                ResultBar(title: AppStrings.wrinkles,     score: record?.wrinkleScore      ?? 0, icon: "sun.max.fill")
                                ResultBar(title: AppStrings.eyebags,      score: record?.eyebagScore       ?? 0, icon: "eye.fill")
                                ResultBar(title: AppStrings.pigmentation, score: record?.pigmentationScore ?? 0, icon: "circle.hexagongrid")
                            } else {
                                Button { showUpgrade = true } label: { ResultBar(title: AppStrings.wrinkles, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                Button { showUpgrade = true } label: { ResultBar(title: AppStrings.eyebags, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                                Button { showUpgrade = true } label: { ResultBar(title: AppStrings.pigmentation, score: 0, icon: "lock.fill", locked: true) }.buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Recommended Products
                    // Always drawn. Hiding the list behind a "see
                    // recommendations" tap meant a fresh scan ended on a screen
                    // that appeared to have no products at all.
                    VStack(alignment: .leading, spacing: 16) {
                        Text(vm.isGeneralCare ? AppStrings.generalCareProducts : AppStrings.recommendedProducts)
                            .font(.scaled(size: 18, weight: .bold))
                            .foregroundColor(.brandText)

                        if vm.isLoading {
                            // Placeholders in the shape of the rows that are
                            // coming, so nothing jumps when they land.
                            VStack(spacing: 16) {
                                ForEach(0..<3, id: \.self) { _ in
                                    SkeletonRow()
                                }
                            }
                        } else if let error = vm.errorMessage, vm.recommendProduct.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(error)
                                    .font(.scaled(size: 14))
                                    .foregroundColor(.gray)
                                Button(AppStrings.tryAgain) {
                                    Task { await vm.fetchRecommendedProducts() }
                                }
                                .font(.scaled(size: 14, weight: .bold))
                                .foregroundColor(.brandPrimary)
                            }
                        } else if vm.recommendProduct.isEmpty {
                            // An empty catalogue answer still says something;
                            // the header used to sit above blank space.
                            Text(AppStrings.noProductsFound)
                                .font(.scaled(size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(visibleProducts) { product in
                                    Button {
                                        selectedProduct = product
                                    } label: {
                                        SearchProductCard(product: product)
                                    }
                                    .buttonStyle(.plain)
                                }

                                // A stacked list gives no hint that more exist
                                // below the free cut-off, the way a scroller did.
                                if hiddenProductCount > 0 {
                                    Button { showUpgrade = true } label: {
                                        lockedProductsRow
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Action Button
                    if !vm.recommendProduct.isEmpty {
                        Button(action: {
                            createRoutineFromProducts()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: routineCreated ? "checkmark.circle.fill" : "calendar.badge.plus")
                                    .font(.scaled(size: 20))
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
                        .font(.scaled(size: 12))
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
                    .font(.scaled(size: 16, weight: .bold))
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
        // No-op when this screen is a cover; restores the edge pop when
        // Recents pushes it onto a NavigationStack.
        .interactiveSwipeBack()
        .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
        // item-based so the sheet body always carries the tapped product;
        // the isPresented+if-let form intermittently presents blank.
        .sheet(item: $selectedProduct) { product in
            NavigationStack {
                DetailView(type: .product(product))
            }
        }
        .fullScreenCover(isPresented: $showRoutine) {
            NavigationStack {
                RoutineView(selectedTab: .constant(0))
                    .edgeSwipeToDismiss { showRoutine = false }
            }
        }
    }

    /// Same shape as the product rows above it, so the locked remainder reads
    /// as the next item in the list rather than a banner bolted underneath.
    private var lockedProductsRow: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(Color.brandBlush)
                    .frame(width: 60, height: 60)

                Image(systemName: "lock.fill")
                    .font(.scaled(size: 22))
                    .foregroundColor(.brandPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.fullRecommendations)
                    .font(.scaled(size: 16, weight: .bold))
                    .foregroundColor(.brandText)
                    .lineLimit(1)

                Text(AppStrings.pro)
                    .font(.scaled(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.brandBlush)
                    .foregroundColor(.brandPrimary)
                    .cornerRadius(Radius.small)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.scaled(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
    }

    private func closeResult() {
        // Exactly one dismissal mechanism: the owner's closure when there is
        // one (it pops the presenting state itself), the environment dismiss
        // otherwise. Running both pops two levels from Recents and double-
        // resets the camera.
        if let onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }

    private func createRoutineFromProducts() {
        // The routine screen is Pro-only; writing items a free user cannot
        // open would just strand invisible rows. Offer the upgrade instead.
        guard isPremium else {
            showUpgrade = true
            return
        }

        let products = vm.recommendProduct
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
                // Same dedupe rule as acceptSuggestion: one product per
                // step slot, or the extra row becomes an invisible orphan
                // the routine screen can never show or delete.
                if let duplicate = manager.fetchRoutineItems(for: time)
                    .first(where: { $0.stepOrder == mapping.order }) {
                    manager.deleteRoutineItem(duplicate)
                }
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
        // No delayed presentation: a timer would still fire (and present a
        // full-screen cover) after the user has already left this screen.
        showRoutine = true
    }
}

// MARK: - ResultBar Struct
struct ResultBar: View {
    let title: String
    let score: Double
    let icon: String
    var locked: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(locked ? Color.gray.opacity(0.15) : Color.brandPrimary)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.scaled(size: 20))
                    .foregroundColor(locked ? .gray.opacity(0.5) : .white)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(title)
                        .font(.scaled(size: 16, weight: .bold))
                        .foregroundColor(locked ? .gray.opacity(0.5) : .brandText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 8)

                    if locked {
                        Text(AppStrings.pro)
                            .font(.scaled(size: 12, weight: .bold))
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.brandBlush)
                            .cornerRadius(Radius.small)
                    } else {
                        Text("\(Int(score))")
                            .font(.scaled(size: 20, weight: .bold))
                            .foregroundColor(.brandPrimary)

                        Text("/100")
                            .font(.scaled(size: 13, weight: .semibold))
                            .foregroundColor(.gray)

                        Text(Severity(score: score).localizedTitle)
                            .font(.scaled(size: 11, weight: .semibold))
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.brandBlush)
                            .cornerRadius(Radius.small)
                            .padding(.leading, 8)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Radius.small)
                            .fill(locked ? Color.gray.opacity(0.12) : Color.brandPrimary.opacity(0.1))
                            .frame(height: 6)
                        if !locked {
                            RoundedRectangle(cornerRadius: Radius.small)
                                .fill(Color.brandPrimary)
                                .frame(width: geo.size.width * (min(max(score, 0), 100) / 100), height: 6)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(Radius.card)
        .cardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            locked
                ? Text("\(title), \(AppStrings.pro)")
                : Text("\(title): \(Int(score))/100, \(Severity(score: score).localizedTitle)")
        )
    }
}

#Preview {
    ResultView(record: nil, isFromRecents: true)
}

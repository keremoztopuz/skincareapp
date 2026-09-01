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

    /// Acne and redness are free, the other three are Pro — the split is by
    /// condition, not by position, so the rows can be sorted freely.
    private var freeReadings: [ConditionReading] {
        [
            ConditionReading(title: AppStrings.acne,    score: record?.acneScore   ?? 0),
            ConditionReading(title: AppStrings.redness, score: record?.eczemaScore ?? 0)
        ]
    }

    private var proReadings: [ConditionReading] {
        [
            ConditionReading(title: AppStrings.wrinkles,     score: record?.wrinkleScore      ?? 0),
            ConditionReading(title: AppStrings.eyebags,      score: record?.eyebagScore       ?? 0),
            ConditionReading(title: AppStrings.pigmentation, score: record?.pigmentationScore ?? 0)
        ]
    }

    /// Worst first, so the card leads with the finding that needs attention.
    private var visibleReadings: [ConditionReading] {
        let readings = isPremium ? freeReadings + proReadings : freeReadings
        return readings.sorted { $0.score > $1.score }
    }

    private var lockedReadings: [ConditionReading] {
        isPremium ? [] : proReadings
    }

    /// The three locked conditions as one row. Three identical empty cards
    /// said the same thing three times and read as padding.
    private var lockedReadingsRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.scaled(size: 15))
                .foregroundColor(.brandPrimary)

            Text(ListFormatter.localizedString(byJoining: lockedReadings.map(\.title)))
                .font(.scaled(size: 15, weight: .semibold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Text(AppStrings.pro)
                .font(.scaled(size: 12, weight: .bold))
                .foregroundColor(.brandPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.brandBlush)
                .cornerRadius(Radius.small)

            Image(systemName: "chevron.right")
                .font(.scaled(size: 13, weight: .bold))
                .foregroundColor(.gray.opacity(0.3))
        }
    }

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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppStrings.results)
                                .font(.scaled(size: 18, weight: .bold))
                                .foregroundColor(.brandText)

                            // The overall score on this same screen runs the
                            // other way, so the readings have to name their
                            // direction or 68 reads as healthier than 21.
                            Text(AppStrings.conditionScaleHint)
                                .font(.scaled(size: 12))
                                .foregroundColor(.gray)
                        }

                        // One card, one axis. The five severities share a
                        // scale, so they belong on a common baseline: in
                        // separate cards they were five unrelated facts and
                        // nothing said which finding mattered.
                        VStack(spacing: 0) {
                            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 14) {
                                ForEach(visibleReadings) { reading in
                                    GridRow {
                                        Text(reading.title)
                                            .font(.scaled(size: 15, weight: .semibold))
                                            .foregroundColor(.brandText)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)

                                        ConditionAxisBar(score: reading.score)

                                        Text("\(Int(reading.score))")
                                            .font(.scaled(size: 16, weight: .bold))
                                            .foregroundColor(.brandText)
                                            .monospacedDigit()
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel(
                                        Text("\(reading.title): \(Int(reading.score))/100, \(Severity(score: reading.score).localizedTitle)")
                                    )
                                }
                            }

                            if !lockedReadings.isEmpty {
                                Divider()
                                    .padding(.vertical, 16)

                                Button { showUpgrade = true } label: {
                                    lockedReadingsRow
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(Radius.card)
                        .cardShadow()
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

// MARK: - Condition axis

/// One measured condition. A value type so the rows can be sorted and the
/// free/Pro split stays a property of the condition, not of its position.
struct ConditionReading: Identifiable {
    let title: String
    let score: Double

    var id: String { title }
}

/// A single severity on the shared 0-100 axis.
///
/// The track spans the whole column, so every bar in the card starts and ends
/// at the same x and their lengths compare directly — the point of putting the
/// readings in one card instead of five.
struct ConditionAxisBar: View {
    let score: Double

    private var fraction: Double { min(max(score, 0), 100) / 100 }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.brandPrimary.opacity(0.08))

                Capsule()
                    .fill(Severity(score: score).tint)
                    // A zero-width capsule draws nothing at all; the floor
                    // keeps a near-zero reading visible as a dot.
                    .frame(width: max(geo.size.width * fraction, 8))
            }
        }
        .frame(height: 8)
        .frame(minWidth: 60, maxWidth: .infinity)
    }
}

#Preview {
    ResultView(record: nil, isFromRecents: true)
}

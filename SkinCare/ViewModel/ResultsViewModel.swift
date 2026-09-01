//
//  ResultsViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI
internal import Combine

class ResultsViewModel: ObservableObject {
    @Published var record: AnalysisRecord?
    @Published var recommendation: [String] = []
    @Published var recommendProduct: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// True when no condition crossed its threshold and the list below is the
    /// everyday routine rather than an answer to a problem. The section title
    /// should say so — these products are not "for" anything the scan found.
    @Published var isGeneralCare: Bool = false

    /// True when the screen shows a stored record from history. Routine
    /// suggestions belong to a fresh scan only — regenerating them on every
    /// history visit re-creates suggestion rows and inflates the badge on
    /// Home.
    private let isHistorical: Bool

    init(record: AnalysisRecord?, isHistorical: Bool = false) {
        self.record = record
        self.isHistorical = isHistorical
        Task {
            await generateRecommendations()
        }
    }

    //MARK: Personalized recommendations algorithm

    @MainActor
    func generateRecommendations() async {
        guard let record = self.record else {
            recommendation = [String(localized: "recommendation_keep_hydrated")]
            // No record, no products: leave isLoading false so the view can
            // show its empty state instead of a spinner that never resolves.
            return
        }

        isLoading = true

        let conditions = ConditionDetector.activeConditions(from: record)
        recommendation = adviceLines(for: conditions, record: record)

        await fetchRecommendedProducts()

        if !isHistorical {
            let skinType = LocalPersistenceManager.shared.fetchUserProfile()?.skinType ?? SkinType.normal.rawValue
            let suggestions = await RoutineEngine.shared.generateRoutine(from: record, skinType: skinType)
            if !suggestions.isEmpty {
                LocalPersistenceManager.shared.saveSuggestions(suggestions)
            }
        }

        isLoading = false
    }

    /// Product fetch on its own, so a retry does not re-run the routine
    /// suggestion pass and duplicate the suggestions of a fresh scan.
    @MainActor
    func fetchRecommendedProducts() async {
        guard let record = self.record else { return }
        errorMessage = nil

        let conditions = ConditionDetector.activeConditions(from: record)
        isGeneralCare = conditions.isEmpty

        let outcome = conditions.isEmpty
            ? await fetchGeneralCare()
            : await fetchProducts(for: conditions)

        recommendProduct = outcome.products
        // Partial success still has something to show, so only a completely
        // empty list is reported as a failure.
        if outcome.products.isEmpty, let error = outcome.error {
            errorMessage = AppStrings.loadFailureMessage(for: error)
        }
    }

    // MARK: - Fetching

    private typealias FetchOutcome = (products: [Product], error: Error?)

    /// Every active condition, in parallel.
    ///
    /// A product linked to more than one of them is kept once and carries the
    /// sum of their weights, so the worst condition's answer leads the list —
    /// which matters because the free tier only shows the first two.
    private func fetchProducts(for conditions: [(key: String, weight: Double)]) async -> FetchOutcome {
        let results = await withTaskGroup(
            of: (weight: Double, products: [Product], error: Error?).self
        ) { group -> [(weight: Double, products: [Product], error: Error?)] in
            for condition in conditions {
                group.addTask {
                    do {
                        let products = try await CatalogueService.shared
                            .fetchRecommendedProducts(for: condition.key)
                        return (condition.weight, products, nil)
                    } catch {
                        AppLog.error("Condition product fetch failed", error)
                        return (condition.weight, [], error)
                    }
                }
            }
            var collected: [(weight: Double, products: [Product], error: Error?)] = []
            for await result in group { collected.append(result) }
            return collected
        }

        var order: [UUID] = []
        var byID: [UUID: Product] = [:]
        var weights: [UUID: Double] = [:]

        for result in results {
            for product in result.products {
                if byID[product.id] == nil {
                    order.append(product.id)
                    byID[product.id] = product
                }
                weights[product.id, default: 0] += result.weight
            }
        }

        // `order` breaks ties so the list does not reshuffle between fetches:
        // the task group finishes in whatever order the network answers.
        let sorted = order
            .enumerated()
            .sorted { lhs, rhs in
                let left = weights[lhs.element] ?? 0
                let right = weights[rhs.element] ?? 0
                return left == right ? lhs.offset < rhs.offset : left > right
            }
            .compactMap { byID[$0.element] }

        return (sorted, results.compactMap(\.error).first)
    }

    /// Clear skin still deserves a shelf: one or two staples per routine step
    /// instead of a section that draws nothing.
    private func fetchGeneralCare() async -> FetchOutcome {
        var products: [Product] = []
        var firstError: Error?

        for type in ConditionDetector.generalCareProductTypes {
            do {
                let matches = try await CatalogueService.shared.fetchProductsByType(type)
                products.append(contentsOf: matches.prefix(2))
            } catch {
                AppLog.error("General care product fetch failed", error)
                if firstError == nil { firstError = error }
            }
        }

        return (products, firstError)
    }

    // MARK: - Advice copy

    private func adviceLines(
        for conditions: [(key: String, weight: Double)],
        record: AnalysisRecord
    ) -> [String] {
        var lines: [String] = []

        // Ordered by weight already, so the worst condition is advised first.
        for condition in conditions {
            switch condition.key {
            case "acne": lines.append(String(localized: "condition_recommendation_acne"))
            case "redness": lines.append(String(localized: "condition_recommendation_redness"))
            case "pigmentation": lines.append(String(localized: "condition_recommendation_pigmentation"))
            case "wrinkles": lines.append(String(localized: "condition_recommendation_wrinkles"))
            case "eyebags": lines.append(String(localized: "condition_recommendation_eyebags"))
            default: break
            }
        }

        // Hydration is the one inverted score, and it has its own line even
        // when it already routed to the redness key above.
        if record.hydrationScore < 45.0 {
            lines.append(String(localized: "condition_recommendation_hydration"))
        }

        return lines.isEmpty ? [String(localized: "recommendation_keep_hydrated")] : lines
    }
}

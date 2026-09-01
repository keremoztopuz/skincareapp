import Foundation

struct RoutineRecommendation {
    let routineTime: String
    let stepOrder: Int16
    let stepLabel: String
    let product: Product
    let relevanceScore: Double
}

class RoutineEngine {
    static let shared = RoutineEngine()
    private init() {}

    private struct RoutineStep {
        let order: Int16
        let label: String
        let morningTypes: [String]
        let eveningTypes: [String]
    }

    private let steps: [RoutineStep] = [
        RoutineStep(order: 0, label: "Cleanser", morningTypes: ["cleanser"], eveningTypes: ["cleanser"]),
        RoutineStep(order: 1, label: "Serum", morningTypes: ["serum"], eveningTypes: ["treatment"]),
        RoutineStep(order: 2, label: "Eye Care", morningTypes: [], eveningTypes: ["eye_cream", "eye_serum"]),
        RoutineStep(order: 3, label: "Moisturizer", morningTypes: ["moisturizer"], eveningTypes: ["moisturizer"]),
        RoutineStep(order: 4, label: "Sunscreen", morningTypes: ["sunscreen"], eveningTypes: [])
    ]

    func generateRoutine(from record: AnalysisRecord, skinType: String) async -> [RoutineRecommendation] {
        let activeConditions = ConditionDetector.activeConditions(from: record)

        guard !activeConditions.isEmpty else { return [] }

        var allProducts: [(product: Product, conditionScores: [String: Double])] = []

        for (conditionKey, score) in activeConditions {
            do {
                let products = try await CatalogueService.shared.fetchRecommendedProducts(for: conditionKey)
                for product in products {
                    if let existing = allProducts.firstIndex(where: { $0.product.id == product.id }) {
                        allProducts[existing].conditionScores[conditionKey] = score
                    } else {
                        allProducts.append((product: product, conditionScores: [conditionKey: score]))
                    }
                }
            } catch {
                AppLog.error("Condition product fetch failed", error)
            }
        }

        var recommendations: [RoutineRecommendation] = []

        for step in steps {
            for (time, types) in [("morning", step.morningTypes), ("evening", step.eveningTypes)] {
                guard !types.isEmpty else { continue }

                let candidates = allProducts.filter { item in
                    guard let pt = item.product.productType else { return false }
                    return types.contains(pt)
                }

                guard let best = rankProducts(candidates, skinType: skinType) else { continue }

                recommendations.append(RoutineRecommendation(
                    routineTime: time,
                    stepOrder: step.order,
                    stepLabel: step.label,
                    product: best.product,
                    relevanceScore: best.score
                ))
            }
        }

        return recommendations
    }

    private func rankProducts(_ candidates: [(product: Product, conditionScores: [String: Double])], skinType: String) -> (product: Product, score: Double)? {
        guard !candidates.isEmpty else { return nil }

        var scored: [(product: Product, score: Double)] = []

        for candidate in candidates {
            var score = candidate.conditionScores.values.reduce(0, +)

            if let productSkinTypes = candidate.product.skinTypes, !productSkinTypes.isEmpty {
                if productSkinTypes.contains(where: { $0.lowercased() == skinType.lowercased() }) {
                    score += 0.5
                } else {
                    score -= 0.3
                }
            }

            scored.append((product: candidate.product, score: score))
        }

        return scored.max(by: { $0.score < $1.score })
    }
}

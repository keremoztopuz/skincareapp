//
//  ScoringEngine.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 26.03.2026.
//

import Foundation

struct SkinScore {
    let overallScore: Double
    let oilinessScore: Double
    let inflammationScore: Double
    let dominantCondition: String
}

/// Converts the five measured condition severities (0-1) into the derived
/// metrics shown in the app.
///
/// The analysis produces five classes — acne, redness, wrinkles, eyebags,
/// pigmentation — plus a direct hydration reading. Hydration is surfaced as a
/// metric on its own; oiliness and inflammation are derived here, and
/// `overallScore` is computed once from the raw inputs (never from the derived
/// metrics) to avoid double counting.
///
/// All formulas use exponential soft saturation instead of linear sums with
/// hard caps, so the full 0-100 range is usable and extreme inputs cannot
/// silently flatline. Skin type contributes small load intercepts plus
/// susceptibility multipliers on individual weights, so the measured evidence
/// always dominates the self-reported profile.
class ScoringEngine {

    func calculateScore(
        acne: Double,
        redness: Double,
        pigmentation: Double,
        wrinkles: Double = 0,
        eyebags: Double = 0,
        hydration: Double,
        skinType: String
    ) -> SkinScore {
        let type = normalizedSkinType(skinType)

        // MARK: Overall (higher = better)
        // Susceptibility multipliers per skin type; unlisted weights stay at 1.0.
        let acneWeight: Double = 1.00 * (type == "oily" ? 1.15 : (type == "combination" ? 1.05 : 1.0))
        let rednessWeight: Double = 0.80 * (type == "sensitive" ? 1.25 : (type == "dry" ? 1.10 : 1.0))
        let pigmentationWeight: Double = 0.50
        let wrinkleWeight: Double = 0.35
        let eyebagWeight: Double = 0.25
        // Dehydration counts toward overall too — without it a severely
        // dehydrated but otherwise clear face scored ~98 while its hydration
        // metric read ~30. Weighted below the primary conditions: hydration is
        // a real reading, but a dry face is not an unhealthy face.
        let dehydrationWeight: Double = 0.40

        // Floor keeps a perfect scan at ~98 instead of a fake 100.
        let load = 0.02
            + acneWeight * acne
            + rednessWeight * redness
            + pigmentationWeight * pigmentation
            + wrinkleWeight * wrinkles
            + eyebagWeight * eyebags
            + dehydrationWeight * (1.0 - hydration)
        let overallScore = clamp(100.0 * exp(-load))

        // MARK: Inflammation (higher = worse)
        let inflammationBase: Double
        switch type {
        case "sensitive": inflammationBase = 0.15
        case "oily", "combination": inflammationBase = 0.08
        default: inflammationBase = 0.05
        }
        let rednessBoost: Double = type == "sensitive" ? 1.2 : 1.0
        let inflammationLoad = inflammationBase
            + 1.6 * acne
            + 1.4 * redness * rednessBoost
            + 0.3 * pigmentation
        let inflammationScore = clamp(100.0 * (1.0 - exp(-inflammationLoad)))

        // MARK: Oiliness (higher = worse)
        // Base-heavy by necessity: there is no direct sebum measurement, acne
        // is the only correlated signal.
        let oilinessBase: Double
        switch type {
        case "oily": oilinessBase = 0.90
        case "combination": oilinessBase = 0.55
        case "sensitive": oilinessBase = 0.30
        case "dry": oilinessBase = 0.10
        default: oilinessBase = 0.35
        }
        let oilinessLoad = oilinessBase + 0.9 * acne
        let oilinessScore = clamp(100.0 * (1.0 - exp(-oilinessLoad)))

        // MARK: Dominant condition
        let scores = ["acne": acne, "redness": redness, "pigmentation": pigmentation]
        let top = scores.max(by: { $0.value < $1.value })
        let dominantCondition = (top?.value ?? 0) > 0.25 ? (top?.key ?? "") : ""

        return SkinScore(
            overallScore: overallScore,
            oilinessScore: oilinessScore,
            inflammationScore: inflammationScore,
            dominantCondition: dominantCondition
        )
    }

    private func normalizedSkinType(_ skinType: String) -> String {
        let type = skinType.lowercased()
        return type == "combo" ? "combination" : type
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.0), 100.0)
    }
}

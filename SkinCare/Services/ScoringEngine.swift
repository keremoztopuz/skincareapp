//
//  ScoringEngine.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 26.03.2026.
//

import Foundation

struct SkinScore {
    let overallScore: Double
    let drynessScore: Double
    let oilinessScore: Double
    let inflammationScore: Double
    let dominantCondition: String
}

class ScoringEngine {

    func calculateScore(acne: Double, redness: Double, pigmentation: Double, hydration: Double, skinType: String) -> SkinScore {
        let oilinessBase: Double
        switch skinType{
            case "oily": oilinessBase = 70.0
            case "dry": oilinessBase = 10.0
            case "combo": oilinessBase = 50.0
            default: oilinessBase = 35.0
        }

        let oilinessScore = min(oilinessBase + acne * 25.0, 100.0)

        let drynessBase: Double
        switch skinType {
            case "dry": drynessBase = 70.0
            case "oily": drynessBase = 10.0
            case "combo": drynessBase = 50.0
            default: drynessBase = 35.0
        }

        let hydrationPenalty = max(0, (1.0 - hydration)) * 30.0
        let drynessScore = min(drynessBase + redness * 35.0 + hydrationPenalty, 100.0)

        let inflammationBase: Double
        switch skinType {
            case "sensitive": inflammationBase = 70.0
            case "oily": inflammationBase = 30.0
            case "dry": inflammationBase = 10.0
            case "combo": inflammationBase = 50.0
            default: inflammationBase = 35.0
        }

        let inflammationScore = min(inflammationBase + acne * 45.0 + redness * 35.0 + pigmentation * 15.0, 100.0)

        let overallScore = max(0.0, min(hydration * 30.0 + 50.0 - inflammationScore * 0.30 - drynessScore * 0.10 - oilinessScore * 0.10 - pigmentation * 10.0, 100.0))

        let scores = ["acne": acne, "redness": redness, "pigmentation": pigmentation]
        let top = scores.max(by: { $0.value < $1.value })
        let dominantCondition = (top?.value ?? 0) > 0.25 ? (top?.key ?? "") : ""

        return SkinScore(overallScore: overallScore, drynessScore: drynessScore, oilinessScore: oilinessScore, inflammationScore: inflammationScore, dominantCondition: dominantCondition)
    }

}

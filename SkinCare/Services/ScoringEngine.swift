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
    
    func calculateScore(acne: Double, eczema: Double, psoriasis: Double, benLezyon: Double, healthy: Double, skinType: String) -> SkinScore {
        let oilinessBase: Double
        // oiliness
        switch skinType{
            case "oily": oilinessBase = 70.0
            case "dry": oilinessBase = 10.0
            case "combo": oilinessBase = 50.0
            default: oilinessBase = 35.0 // normal
        } 

        let oilinessScore = min(oilinessBase + acne * 25.0, 100.0)

        // dryness
        let drynessBase: Double
        switch skinType {
            case "dry": drynessBase = 70.0
            case "oily": drynessBase = 10.0
            case "combo": drynessBase = 50.0
            default: drynessBase = 35.0 // normal
        }

        let drynessScore = min(drynessBase + eczema * 35.0 + psoriasis * 25.0, 100.0)

        // inflammation
        let inflammationBase: Double
        switch skinType {
            case "sensitive": inflammationBase = 70.0
            case "oily": inflammationBase = 30.0
            case "dry": inflammationBase = 10.0 
            case "combo": inflammationBase = 50.0
            default: inflammationBase = 35.0 // normal
        }

        let inflammationScore = min(inflammationBase + acne * 45.0 + eczema * 35.0 + psoriasis * 20.0, 100.0)

        // overall
        let overallScore = max(0.0, min(healthy * 60.0 + 40.0 - inflammationScore * 0.35 - drynessScore * 0.10 - oilinessScore * 0.10, 100.0))

        let scores = ["acne": acne, "eczema": eczema, "psoriasis": psoriasis, "ben_Lezyon": benLezyon]
        let top = scores.max(by: { $0.value < $1.value })
        let dominantCondition = (top?.value ?? 0) > 0.25 ? (top?.key ?? "") : ""

        return SkinScore(overallScore: overallScore, drynessScore: drynessScore, oilinessScore: oilinessScore, inflammationScore: inflammationScore, dominantCondition: dominantCondition)
    }
    
}
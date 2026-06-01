//
//  SkinCondition.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation

// MARK: Skin Classes
enum SkinCondition: String, Codable, CaseIterable, Identifiable{
    case acne
    case redness
    case pigmentation
    case wrinkles
    case eyebags
    case hydration

    var id : String { self.rawValue }

    var recommendation: String {
        switch self {
        case .acne:
            return String(localized: "condition_recommendation_acne")
        case .redness:
            return String(localized: "condition_recommendation_redness")
        case .pigmentation:
            return String(localized: "condition_recommendation_pigmentation")
        case .wrinkles:
            return String(localized: "condition_recommendation_wrinkles")
        case .eyebags:
            return String(localized: "condition_recommendation_eyebags")
        case .hydration:
            return String(localized: "condition_recommendation_hydration")
        }
    }
}

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
    case psoriasis
    case wrinkles
    case eyebags
    
    
    var id : String { self.rawValue }
    
// MARK: Descriptions for testing
    var recommendation: String {
        switch self {
        case .acne:
            return "Use cleansers containing salicylic acid. Prefer non-comedogenic moisturizers."
        case .redness:
            return "Use soothing products containing Centella or Niacinamide. Avoid harsh scrubs and extreme temperatures."
        case .psoriasis:
            return "Use intensive moisturizers and anti-scaling ingredients. Definitely consult a specialist dermatologist."
        case .wrinkles:
            return "Use products containing retinol and peptides. Protect your skin from the sun and drink plenty of water."
        case .eyebags:
            return "Apply cold compresses and prefer under-eye creams containing caffeine. Pay attention to your sleep pattern."
        }
    }
}

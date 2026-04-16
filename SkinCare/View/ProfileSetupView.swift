//
//  ProfileSetupView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 14.04.2026.
//

import SwiftUI
// gender modification
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Prefer not to say"
}
// skin type modification
enum SkinType: String, CaseIterable {
    case normal = "Normal"
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case sensitive = "Sensitive"
    // icons
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle"
        case .dry: return "drop"
        case .oily: return "humidity"
        case .combination: return "circle.lefthalf.filled"
        case .sensitive: return "heart"
        }
    }
    // skin type description
    var description: String {
        switch self {
        case .normal: return "No major concerns."
        case .dry: return "Feels tight, may flake."
        case .oily: return "Shiny, feels greasy."
        case .combination: return "Oily T-zone, dry cheeks."
        case .sensitive: return "Reacts easily to products."
        }
    }
}
#Preview {
    ProfileSetupView()
}



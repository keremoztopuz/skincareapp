import Foundation

enum SkinType: String, CaseIterable {
    case normal = "Normal"
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case sensitive = "Sensitive"

    var icon: String {
        switch self {
        case .normal: return "checkmark.circle"
        case .dry: return "drop"
        case .oily: return "humidity"
        case .combination: return "circle.lefthalf.filled"
        case .sensitive: return "heart"
        }
    }

    var localizedTitle: String {
        AppStrings.localizedSkinType(rawValue)
    }

    var description: String {
        switch self {
        case .normal: return String(localized: "skin_type_desc_normal")
        case .dry: return String(localized: "skin_type_desc_dry")
        case .oily: return String(localized: "skin_type_desc_oily")
        case .combination: return String(localized: "skin_type_desc_combination")
        case .sensitive: return String(localized: "skin_type_desc_sensitive")
        }
    }
}

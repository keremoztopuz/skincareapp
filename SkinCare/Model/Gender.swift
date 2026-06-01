import Foundation

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Prefer not to say"

    var localizedTitle: String {
        AppStrings.localizedGender(rawValue)
    }
}

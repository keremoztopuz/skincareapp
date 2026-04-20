//
//  ProfileSetupViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 18.04.2026.
//

import Foundation
import SwiftUI
import CoreData
internal import Combine

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

class ProfileSetupViewModel: ObservableObject {
      @Published var currentPage = 0
      @Published var name = ""
      @Published var age = 25
      @Published var gender: Gender? = nil
      @Published var skinType: SkinType? = nil
      @Published var showNameWarning = false
   
      func handleContinue() {
          if currentPage == 0 {
              if name.trimmingCharacters(in:
                    .whitespaces).isEmpty {
                  showNameWarning = true
              } else {
                  showNameWarning = false
                  currentPage = 1
              }
          } else if currentPage < 3 {
              currentPage += 1
          } else {
              completeProfile()
          }
      }

    func completeProfile() {
          let manager = LocalPersistenceManager()
          manager.saveUserProfile(
              name: name,
              skinType: skinType?.rawValue ?? "Normal",
              ageRange: String(age),
              knownIssues: ""
          )
          UserDefaults.standard.set(true, forKey:
      "hasCompletedProfile")
      }
  }

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

class ProfileSetupViewModel: ObservableObject {
      @Published var currentPage = 0
      @Published var name = ""
      @Published var age = 25
      @Published var gender: Gender? = nil
      @Published var skinType: SkinType? = nil
      @Published var didFinish = false

    var isCurrentPageValid: Bool {
        switch currentPage {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return true
        case 2: return gender != nil
        case 3: return skinType != nil
        default: return false
        }
    }

    func handleContinue() {
        if currentPage < 3 {
            currentPage += 1
        } else {
            completeProfile()
        }
    }

    func completeProfile() {
        let manager = LocalPersistenceManager.shared
          manager.saveUserProfile(
              name: name,
              skinType: skinType?.rawValue ?? "Normal",
              ageRange: String(age),
              gender: gender?.rawValue ?? "Prefer not to say",
              knownIssues: ""
          )
          didFinish = true
      }
  }

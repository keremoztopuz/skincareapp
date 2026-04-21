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
      @Published var showNameWarning = false
      @Published var showGenderWarning = false
      @Published var showSkinTypeWarning = false

      func handleContinue() {
          if currentPage == 0 {
              if name.trimmingCharacters(in:
                    .whitespaces).isEmpty {
                  showNameWarning = true
              } else {
                  showNameWarning = false
                  currentPage = 1
              }
          } else if currentPage == 1 {
              currentPage = 2
          } else if currentPage == 2 {
              if gender == nil {
                  showGenderWarning = true
              } else {
                  showGenderWarning = false
                  currentPage = 3
              }
          } else {
              if skinType == nil {
                  showSkinTypeWarning = true
              } else {
                  showSkinTypeWarning = false
                  completeProfile()
              }
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
          UserDefaults.standard.set(true, forKey:
      "hasCompletedProfile")
      }
  }

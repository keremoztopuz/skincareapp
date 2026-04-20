//
//  ContentViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI
internal import Combine

enum AppState {
    case onboarding
    case profileSetup
    case mainApp
}

class ContentViewModel: ObservableObject {
      @Published var hasCompletedOnBoarding: Bool {
          didSet {
                                                      
  UserDefaults.standard.set(hasCompletedOnBoarding,
  forKey: "hasCompletedOnBoarding")
          }
      }
      @Published var hasCompletedProfile: Bool {
          didSet {
   
  UserDefaults.standard.set(hasCompletedProfile,
  forKey: "hasCompletedProfile")
          }
      }

      var currentState: AppState {
          if !hasCompletedOnBoarding {
              return .onboarding
          } else if !hasCompletedProfile {
              return .profileSetup
          } else {
              return .mainApp
          }
      }

      init() {
          self.hasCompletedOnBoarding =
  UserDefaults.standard.bool(forKey:
  "hasCompletedOnBoarding")
          self.hasCompletedProfile =
  UserDefaults.standard.bool(forKey:
  "hasCompletedProfile")
      }
  }



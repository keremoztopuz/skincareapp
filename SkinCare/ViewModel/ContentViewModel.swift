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
    
    private var observer: Any?

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
          self.hasCompletedOnBoarding = UserDefaults.standard.bool(forKey: "hasCompletedOnBoarding")
          self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
          
          self.observer = NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                let newOnBoarding = UserDefaults.standard.bool(forKey: "hasCompletedOnBoarding")
                let newProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")

                if self?.hasCompletedOnBoarding != newOnBoarding {
                    self?.hasCompletedOnBoarding = newOnBoarding
                }
                if self?.hasCompletedProfile != newProfile {
                    self?.hasCompletedProfile = newProfile
                }
            }
      }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
  }



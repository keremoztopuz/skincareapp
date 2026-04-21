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
    case splash
    case onboarding
    case profileSetup
    case loading
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
    
    @Published var showSplash = true
    @Published var showLoading = false
    private var observer: Any?

      var currentState: AppState {
          if showSplash {
              return .splash
          } else if !hasCompletedOnBoarding {
              return .onboarding
          } else if !hasCompletedProfile {
              return .profileSetup
          } else if showLoading {
              return .loading
          } else {
              return .mainApp
          }
      }

      init() {
          self.hasCompletedOnBoarding = UserDefaults.standard.bool(forKey: "hasCompletedOnBoarding")
          self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
        
          // splash 4.5 saniye görünsün
          DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
              self?.showSplash = false
          }

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
                if newProfile && !(self?.showLoading ?? false) {
                    self?.showLoading = true
                    // Core Data kayıt süresi + minimum 3.5 saniye
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        self?.showLoading = false
                    }
                }
            }
      }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
  }



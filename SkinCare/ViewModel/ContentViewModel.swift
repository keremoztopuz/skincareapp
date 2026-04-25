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
            UserDefaults.standard.set(hasCompletedOnBoarding, forKey: "hasCompletedOnBoarding")
        }
    }
    @Published var hasCompletedProfile: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedProfile, forKey: "hasCompletedProfile")
        }
    }

    @Published var showSplash = true
    @Published var showLoading = false

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
    }

    func completeOnBoarding() {
        hasCompletedOnBoarding = true
    }

    func completeProfile() {
        hasCompletedProfile = true
        showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.showLoading = false
        }
    }
}

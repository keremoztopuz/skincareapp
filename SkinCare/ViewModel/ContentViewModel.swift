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
    case subscription
}

class ContentViewModel: ObservableObject {
    // MARK: - Properties
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
    @Published var hasCompletedSubscription: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedSubscription, forKey: "hasCompletedSubscription")
        }
    }
    
    
    var currentState: AppState {
        if !hasCompletedOnBoarding {
            return .onboarding
        } else if !hasCompletedProfile {
            return .profileSetup
        } else if !hasCompletedSubscription {
            return .subscription
        } else {
            return .mainApp
        }
    }
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnBoarding = UserDefaults.standard.bool(forKey: "hasCompletedOnBoarding")
        self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
        self.hasCompletedSubscription = UserDefaults.standard.bool(forKey: "hasCompletedSubscription")
        
    }
    
    // MARK: - Methods
    func completeOnBoarding() {
        hasCompletedOnBoarding = true
    }
    
    func completeProfile() {
        hasCompletedProfile = true
    }

    func completePurchaseStep(isPremium: Bool) {
        // Only grant premium here; never revoke it. The free path must not
        // overwrite an entitlement RevenueCat may already have restored.
        if isPremium {
            SubscriptionManager.shared.isPremium = true
        }
        hasCompletedSubscription = true
    }
}

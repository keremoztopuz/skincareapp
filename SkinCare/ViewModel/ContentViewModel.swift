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
    case disclaimer
    case profileSetup
    case loading
    case mainApp
    case subscription
}

class ContentViewModel: ObservableObject {
    @Published var hasCompletedOnBoarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnBoarding, forKey: "hasCompletedOnBoarding")
        }
    }
    @Published var hasAcceptedDisclaimer: Bool {
        didSet {
            UserDefaults.standard.set(hasAcceptedDisclaimer, forKey: "hasAcceptedDisclaimer")
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
    
    
    @Published var showSplash = true
    @Published var showLoading = false
    
    var currentState: AppState {
        if showSplash {
            return .splash
        } else if !hasCompletedOnBoarding {
            return .onboarding
        } else if !hasAcceptedDisclaimer {
            return .disclaimer
        } else if !hasCompletedProfile {
            return .profileSetup
        } else if showLoading {
            return .loading
        } else if !hasCompletedSubscription {
            return .subscription
        } else {
            return .mainApp
        }
    }
    
    init() {
        self.hasCompletedOnBoarding = UserDefaults.standard.bool(forKey: "hasCompletedOnBoarding")
        self.hasAcceptedDisclaimer = UserDefaults.standard.bool(forKey: "hasAcceptedDisclaimer")
        self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
        self.hasCompletedSubscription = UserDefaults.standard.bool(forKey: "hasCompletedSubscription")
        
        // splash shows 4.5 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
            self?.showSplash = false
        }
    }
    
    func completeOnBoarding() {
        hasCompletedOnBoarding = true
    }

    func acceptDisclaimer() {
        hasAcceptedDisclaimer = true
    }
    
    func completeProfile() {
        hasCompletedProfile = true
        showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.showLoading = false
        }
    }
    
    func completePurchaseStep(isPremium: Bool) {
        // Only grant premium here; never revoke it. The free path must not
        // overwrite an entitlement RevenueCat may already have restored.
        if isPremium {
            SubscriptionManager.shared.isPremium = true
        }
        self.showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.showLoading = false
            self?.hasCompletedSubscription = true
        }
    }
}

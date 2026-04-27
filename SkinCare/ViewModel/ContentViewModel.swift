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
    case subscription
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
    @Published var hasCompletedSubscription: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedSubscription, forKey: "hasCompletedSubscription")
        }
    }
    
    
    @Published var showSplash = true
    @Published var showLoading = false
    
    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }
    
    var currentState: AppState {
        if showSplash {
            return .splash
        } else if !hasCompletedOnBoarding {
            return .onboarding
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
        self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
        self.hasCompletedSubscription = UserDefaults.standard.bool(forKey: "hasCompletedSubscription")
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        self.hasCompletedOnBoarding = false
        self.hasCompletedProfile = false
        self.hasCompletedSubscription = false
        
        // splash shows 4.5 sec
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
    
    func completePurchaseStep(isPremium: Bool) {
        self.isPremium = isPremium
        self.showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.showLoading = false
            self?.hasCompletedSubscription = true
        }
    }
}

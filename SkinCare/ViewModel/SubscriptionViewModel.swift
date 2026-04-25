//
//  SubscriptionViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 24.04.2026.
//

// MARK: SUBSCRIPTIONS

import Foundation
import SwiftUI
internal import Combine

enum Subscriptions: String, CaseIterable {
    case free
    case premium
}

class SubscriptionViewModel: ObservableObject {
    @Published var selectedSubscription: Subscriptions = .premium
    
    func completePurchase() {
        UserDefaults.standard.set(true, forKey: "hasCompletedSubscription")
    }
}



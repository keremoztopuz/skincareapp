//
//  MoreViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 6.05.2026.
//

import Foundation
import SwiftUI
internal import Combine
internal import CoreData

class MoreViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userAge: String = ""
    @Published var userGender: String = ""
    @Published var userSkinType: String = ""
    @AppStorage("isPremium") var isPremium: Bool = false

    init() { loadProfile() }

    func loadProfile() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        userName    = profile?.name       ?? "—"
        userAge     = profile?.ageRange   ?? "—"
        userGender  = profile?.gender     ?? "—"
        userSkinType = profile?.skinType  ?? "—"
    }
}

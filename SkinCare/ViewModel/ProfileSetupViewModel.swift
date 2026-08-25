//
//  ProfileSetupViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 18.04.2026.
//

import Foundation
import SwiftUI
internal import CoreData
internal import Combine

class ProfileSetupViewModel: ObservableObject {
    private let persistenceManager: LocalPersistenceManager

    init(persistenceManager: LocalPersistenceManager = .shared) {
        self.persistenceManager = persistenceManager
    }

    @Published var currentPage = 0
    @Published var name = "" {
        didSet {
            if !name.isEmpty { showNameWarning = false }
        }
    }
    @Published var age = 25
    @Published var gender: Gender? = nil {
        didSet {
            if gender != nil { showGenderWarning = false }
        }
    }
    @Published var skinType: SkinType? = nil {
        didSet {
            if skinType != nil { showSkinTypeWarning = false }
        }
    }
    @Published var didFinish = false
    @Published var showSaveError = false

    @Published var showNameWarning = false
    @Published var showGenderWarning = false
    @Published var showSkinTypeWarning = false

    var isCurrentPageValid: Bool {
        switch currentPage {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return true
        case 2: return gender != nil
        case 3: return skinType != nil
        default: return false
        }
    }

    func handleContinue() {
        if currentPage < 3 {
            currentPage += 1
        } else {
            completeProfile()
        }
    }

    func completeProfile() {
        // Validation already trims; persist the trimmed form too so the
        // greeting never carries stray whitespace.
        let saved = persistenceManager.saveUserProfile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            skinType: skinType?.rawValue ?? "Normal",
            ageRange: String(age),
            gender: gender?.rawValue ?? "Prefer not to say",
            knownIssues: ""
        )
        // Advancing without a stored profile would leave every downstream
        // personalization reading an empty profile.
        if saved {
            didFinish = true
        } else {
            showSaveError = true
        }
    }
}

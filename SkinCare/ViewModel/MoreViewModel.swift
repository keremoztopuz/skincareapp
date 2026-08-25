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

    // Profile stats
    @Published var totalAnalyses: Int = 0
    @Published var latestScore: Int?
    @Published var memberSince: String = "-"
    @Published var routineStreak: Int = 0

    // No init-time load: the view's onAppear fires on first appearance too,
    // and loading here as well just doubled the work.

    func loadProfile() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        userName    = profile?.name       ?? "-"
        userAge     = profile?.ageRange   ?? "-"
        userGender  = profile?.gender.map(AppStrings.localizedGender) ?? "-"
        userSkinType = profile?.skinType.map(AppStrings.localizedSkinType) ?? "-"
        loadStats(profile: profile)
    }

    private func loadStats(profile: UserProfile?) {
        let records = LocalPersistenceManager.shared.fetchAnalysisRecords()
        totalAnalyses = records.count
        latestScore = records
            .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
            .last
            .map { Int($0.overallScore) }

        if let created = profile?.createdAt {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
            memberSince = formatter.string(from: created)
        } else {
            memberSince = "-"
        }

        routineStreak = computeRoutineStreak()
    }

    /// Consecutive days (ending today, or yesterday if today has no ticks yet)
    /// with at least one completed routine step. The completion store only
    /// keeps 7 days of history, so the streak naturally caps at 7.
    private func computeRoutineStreak() -> Int {
        let store = RoutineCompletionStore.shared
        store.pruneOldEntries()
        let calendar = Calendar.current

        func hasTicks(on date: Date) -> Bool {
            !store.completedIDs(time: "morning", on: date).isEmpty ||
            !store.completedIDs(time: "evening", on: date).isEmpty
        }

        var day = Date()
        if !hasTicks(on: day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while hasTicks(on: day), streak < store.keepDays {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}

//
//  LocalPersistenceManager.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import CoreData

class LocalPersistenceManager {
    private let context = PersistenceController.shared.container.viewContext
    // User Profile
    func saveUserProfile(name: String, skinType: String, ageRange: String, knownIssues: String) {
        let profile = UserProfile(context: context)
        profile.name = name
        profile.skinType = skinType
        profile.ageRange = ageRange
        profile.knownIssues = knownIssues
        profile.createdAt = Date()

        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    // Analysis Records
    func saveAnalysisRecord(condition: String, confidence: Double, date: Date, drynessScore: Double, inflammationScore: Double, oilinessScore: Double, overallScore: Double, userFeedback: Bool) {
        let record = AnalysisRecord(context: context)
        record.condition = condition
        record.confidence = confidence
        record.date = date
        record.drynessScore = drynessScore
        record.inflammationScore = inflammationScore
        record.oilinessScore = oilinessScore
        record.overallScore = overallScore
        record.userFeedback = userFeedback

        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    // Fetching
    func fetchAnalysisRecords() -> [AnalysisRecord] {
        let request: NSFetchRequest<AnalysisRecord> = AnalysisRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    // Fetching User Profile
    func fetchUserProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

}
//
//  LocalPersistenceManager.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
internal import CoreData

class LocalPersistenceManager {
    static let shared = LocalPersistenceManager()
    private init() {
    }
    private let context = PersistenceController.shared.container.viewContext
    // User Profile
    func saveUserProfile(name: String, skinType: String, ageRange: String, gender: String, knownIssues: String) {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        let profile: UserProfile
        if let existingProfile = try? context.fetch(request).first {
            profile = existingProfile
        } else {
            profile = UserProfile(context: context)
            profile.createdAt = Date()
        }
        
        profile.name = name
        profile.skinType = skinType
        profile.ageRange = ageRange
        profile.gender = gender
        profile.knownIssues = knownIssues

        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    // Analysis Records
    @discardableResult
    func saveAnalysisRecord(condition: String, confidence: Double, wrinkleScore: Double, eyebagScore: Double, date: Date, drynessScore: Double, inflammationScore: Double, oilinessScore: Double, overallScore: Double, userFeedback: Bool, acneScore: Double, eczemaScore: Double, psoriasisScore: Double, imageData: Data?) -> AnalysisRecord {
        let record = AnalysisRecord(context: context)
        record.condition = condition
        record.confidence = confidence
        record.date = date
        record.drynessScore = drynessScore
        record.inflammationScore = inflammationScore
        record.oilinessScore = oilinessScore
        record.overallScore = overallScore
        record.userFeedback = userFeedback
        record.acneScore = acneScore
        record.eczemaScore = eczemaScore
        record.psoriasisScore = psoriasisScore
        record.wrinkleScore = wrinkleScore
        record.eyebagScore = eyebagScore
        record.imageData = imageData

        do {
            try context.save()
            return record
        } catch {
            print("Save error: \(error)")
            return record
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
    func deleteAnalysisRecord(_ record: AnalysisRecord) {
        context.delete(record)
        do {
            try context.save()
        } catch {
            print("Delete error: \(error)")
        }
    }

    func fetchUserProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}

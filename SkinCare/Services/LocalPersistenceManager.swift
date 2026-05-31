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
    func saveAnalysisRecord(condition: String, confidence: Double, wrinkleScore: Double, eyebagScore: Double, pigmentationScore: Double, hydrationScore: Double, date: Date, drynessScore: Double, inflammationScore: Double, oilinessScore: Double, overallScore: Double, userFeedback: Bool, acneScore: Double, eczemaScore: Double, imageData: Data?) -> AnalysisRecord {
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
        record.pigmentationScore = pigmentationScore
        record.hydrationScore = hydrationScore
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

    // MARK: - Routine Items

    func fetchRoutineItems(for routineTime: String) -> [RoutineItem] {
        let request: NSFetchRequest<RoutineItem> = RoutineItem.fetchRequest()
        request.predicate = NSPredicate(format: "routineTime == %@", routineTime)
        request.sortDescriptors = [NSSortDescriptor(key: "stepOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func fetchAllRoutineItems() -> [RoutineItem] {
        let request: NSFetchRequest<RoutineItem> = RoutineItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "stepOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func saveRoutineItem(productId: UUID, productName: String, productBrand: String?, productImageUrl: String?, productType: String, routineTime: String, stepOrder: Int16, isManuallyAdded: Bool) {
        let item = RoutineItem(context: context)
        item.id = UUID()
        item.productId = productId
        item.productName = productName
        item.productBrand = productBrand
        item.productImageUrl = productImageUrl
        item.productType = productType
        item.routineTime = routineTime
        item.stepOrder = stepOrder
        item.isManuallyAdded = isManuallyAdded
        item.addedAt = Date()

        do {
            try context.save()
        } catch {
            print("Save routine item error: \(error)")
        }
    }

    func deleteRoutineItem(_ item: RoutineItem) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Delete routine item error: \(error)")
        }
    }

    // MARK: - Routine Suggestions

    func saveSuggestions(_ suggestions: [RoutineRecommendation]) {
        let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
        request.predicate = NSPredicate(format: "isAccepted == NO")
        if let old = try? context.fetch(request) {
            for item in old { context.delete(item) }
        }

        for s in suggestions {
            let suggestion = RoutineSuggestion(context: context)
            suggestion.id = UUID()
            suggestion.productId = s.product.id
            suggestion.productName = s.product.name
            suggestion.productBrand = s.product.brand
            suggestion.productImageUrl = s.product.imageUrl
            suggestion.productType = s.product.productType
            suggestion.routineTime = s.routineTime
            suggestion.stepOrder = s.stepOrder
            suggestion.suggestedAt = Date()
            suggestion.isAccepted = false
        }

        do {
            try context.save()
        } catch {
            print("Save suggestions error: \(error)")
        }
    }

    func fetchPendingSuggestions() -> [RoutineSuggestion] {
        let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
        request.predicate = NSPredicate(format: "isAccepted == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "stepOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func acceptSuggestion(_ suggestion: RoutineSuggestion) {
        let existing = fetchRoutineItems(for: suggestion.routineTime ?? "morning")
        if let duplicate = existing.first(where: { $0.stepOrder == suggestion.stepOrder }) {
            context.delete(duplicate)
        }

        let item = RoutineItem(context: context)
        item.id = UUID()
        item.productId = suggestion.productId
        item.productName = suggestion.productName
        item.productBrand = suggestion.productBrand
        item.productImageUrl = suggestion.productImageUrl
        item.productType = suggestion.productType
        item.routineTime = suggestion.routineTime
        item.stepOrder = suggestion.stepOrder
        item.isManuallyAdded = false
        item.addedAt = Date()

        suggestion.isAccepted = true

        do {
            try context.save()
        } catch {
            print("Accept suggestion error: \(error)")
        }
    }

    func dismissSuggestion(_ suggestion: RoutineSuggestion) {
        context.delete(suggestion)
        do {
            try context.save()
        } catch {
            print("Dismiss suggestion error: \(error)")
        }
    }

    func dismissAllSuggestions() {
        let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
        request.predicate = NSPredicate(format: "isAccepted == NO")
        if let all = try? context.fetch(request) {
            for item in all { context.delete(item) }
        }
        do {
            try context.save()
        } catch {
            print("Dismiss all suggestions error: \(error)")
        }
    }
}

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
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    // User Profile
    /// Returns false when the Core Data save fails, so callers can refuse to
    /// advance a flow that depends on the profile actually existing.
    @discardableResult
    func saveUserProfile(name: String, skinType: String, ageRange: String, gender: String, knownIssues: String) -> Bool {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        // Same ordering as fetchUserProfile: if duplicate rows ever exist,
        // reads and writes must land on the same (newest) profile.
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
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
            return true
        } catch {
            print("Save error: \(error)")
            context.rollback()
            return false
        }
    }
    // Analysis Records
    /// Returns nil when the Core Data save fails, so callers can tell a
    /// persisted record from one that would vanish on the next launch —
    /// a failed save must not burn a scan.
    @discardableResult
    func saveAnalysisRecord(condition: String, confidence: Double, wrinkleScore: Double, eyebagScore: Double, pigmentationScore: Double, date: Date, inflammationScore: Double, oilinessScore: Double, overallScore: Double, acneScore: Double, eczemaScore: Double, hydrationScore: Double, imageData: Data?) -> AnalysisRecord? {
        let record = AnalysisRecord(context: context)
        record.condition = condition
        record.confidence = confidence
        record.date = date
        record.inflammationScore = inflammationScore
        record.oilinessScore = oilinessScore
        record.overallScore = overallScore
        record.acneScore = acneScore
        record.eczemaScore = eczemaScore
        record.pigmentationScore = pigmentationScore
        record.wrinkleScore = wrinkleScore
        record.eyebagScore = eyebagScore
        // Hydration is a measured metric, not a derived one: it comes straight
        // from the analysis and is the only score where higher means better.
        record.hydrationScore = hydrationScore
        record.imageData = imageData

        do {
            try context.save()
            return record
        } catch {
            print("Save error: \(error)")
            context.rollback()
            return nil
        }
    }
    // MARK: - Score schema migration

    /// Recomputes the derived scores of existing records with the current
    /// scoring formulas so history stays comparable after an engine change.
    /// Runs once per schema version, guarded by UserDefaults.
    func migrateScoresIfNeeded() {
        let versionKey = "scoreSchemaVersion"
        let currentVersion = 5
        guard UserDefaults.standard.integer(forKey: versionKey) < currentVersion else { return }

        let skinType = fetchUserProfile()?.skinType?.lowercased() ?? "normal"
        let engine = ScoringEngine()

        for record in fetchAnalysisRecords() {
            // Very old records stored raw scores on a 0-1 scale. The
            // heuristic can only ever see pre-migration records: this runs
            // at launch, before any cloud scan can be taken, and the version
            // flag stops it from touching records created afterwards.
            let rawMax = max(record.acneScore, record.eczemaScore,
                             record.pigmentationScore, record.wrinkleScore)
            let scale: Double = rawMax <= 1.0 ? 1.0 : 100.0

            // Records taken before hydration was measured stored a flat 0,
            // which would now render as "Hydration 0%". 50 is the neutral
            // value the engine assumed for those records all along.
            if record.hydrationScore == 0 {
                record.hydrationScore = 50
            }

            let scores = engine.calculateScore(
                acne: record.acneScore / scale,
                redness: record.eczemaScore / scale,
                pigmentation: record.pigmentationScore / scale,
                wrinkles: record.wrinkleScore / scale,
                eyebags: record.eyebagScore / scale,
                hydration: record.hydrationScore / 100.0,
                skinType: skinType
            )

            record.oilinessScore = scores.oilinessScore
            record.inflammationScore = scores.inflammationScore
            record.overallScore = scores.overallScore
            if record.confidence == 0 {
                record.confidence = max(record.acneScore, record.eczemaScore) / scale
            }
        }

        do {
            try context.save()
            UserDefaults.standard.set(currentVersion, forKey: versionKey)
        } catch {
            // Leaving the version untouched means the migration is retried on
            // the next launch instead of leaving the store half-converted.
            context.rollback()
            print("Score migration save error: \(error)")
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

    /// Removes every user-generated record: profile, analysis history, and routine.
    func deleteAllUserData() {
        let requests: [NSFetchRequest<NSFetchRequestResult>] = [
            UserProfile.fetchRequest(),
            AnalysisRecord.fetchRequest(),
            RoutineItem.fetchRequest(),
            RoutineSuggestion.fetchRequest()
        ]
        for request in requests {
            if let objects = try? context.fetch(request) as? [NSManagedObject] {
                for object in objects {
                    context.delete(object)
                }
            }
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Delete all error: \(error)")
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

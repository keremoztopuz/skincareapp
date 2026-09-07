//
//  LocalPersistenceManager.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
internal import CoreData

class LocalPersistenceManager {
    // MARK: - Properties
    static let shared = LocalPersistenceManager()
    private let context: NSManagedObjectContext

    // MARK: - Initialization
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    // MARK: - Methods
    private func commit(_ changes: () throws -> Void = {}) -> Bool {
        do {
            try changes()
            try context.save()
            return true
        } catch {
            context.rollback()
            AppLog.error("Local data change failed", error)
            return false
        }
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
        do {
            if let existingProfile = try context.fetch(request).first {
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

            try context.save()
            return true
        } catch {
            AppLog.error("Core Data save failed", error)
            context.rollback()
            return false
        }
    }
    // Analysis Records
    /// Returns nil when the Core Data save fails, so callers can tell a
    /// persisted record from one that would vanish on the next launch —
    /// a failed save must not burn a scan.
    @discardableResult
    func saveAnalysisRecord(condition: String, confidence: Double, wrinkleScore: Double, eyebagScore: Double, pigmentationScore: Double, date: Date, inflammationScore: Double, oilinessScore: Double, overallScore: Double, acneScore: Double, eczemaScore: Double, hydrationScore: Double, imageData: Data?, zonesData: Data? = nil) -> AnalysisRecord? {
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
        // Where each condition sits on the photo, as StoredZones JSON. Nil
        // for records from before regions existed — the overlay just stays off.
        record.zonesData = zonesData

        do {
            try context.save()
            return record
        } catch {
            AppLog.error("Core Data save failed", error)
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
            AppLog.error("Score migration save failed", error)
        }
    }

    // Fetching
    func fetchAnalysisRecords() -> [AnalysisRecord] {
        let request: NSFetchRequest<AnalysisRecord> = AnalysisRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            AppLog.error("Core Data fetch failed", error)
            return []
        }
    }
    // Fetching User Profile
    @discardableResult
    func deleteAnalysisRecord(_ record: AnalysisRecord) -> Bool {
        commit { context.delete(record) }
    }

    /// Removes every user-generated record: profile, analysis history, and routine.
    @discardableResult
    func deleteAllUserData() -> Bool {
        let requests: [NSFetchRequest<NSFetchRequestResult>] = [
            UserProfile.fetchRequest(),
            AnalysisRecord.fetchRequest(),
            RoutineItem.fetchRequest(),
            RoutineSuggestion.fetchRequest()
        ]
        do {
            for request in requests {
                let objects = try context.fetch(request) as? [NSManagedObject] ?? []
                for object in objects {
                    context.delete(object)
                }
            }
            try context.save()
            return true
        } catch {
            context.rollback()
            AppLog.error("Delete-all failed", error)
            return false
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

    @discardableResult
    func saveRoutineItem(productId: UUID, productName: String, productBrand: String?, productImageUrl: String?, productType: String, routineTime: String, stepOrder: Int16, isManuallyAdded: Bool) -> Bool {
        commit {
            let request: NSFetchRequest<RoutineItem> = RoutineItem.fetchRequest()
            request.predicate = NSPredicate(format: "routineTime == %@ AND stepOrder == %d", routineTime, stepOrder)
            // Replace the slot in the same save: failure must preserve the old product.
            for existing in try context.fetch(request) { context.delete(existing) }
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
        }
    }

    @discardableResult
    func deleteRoutineItem(_ item: RoutineItem) -> Bool {
        commit { context.delete(item) }
    }

    // MARK: - Routine Suggestions

    @discardableResult
    func saveSuggestions(_ suggestions: [RoutineRecommendation]) -> Bool {
        commit {
            let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
            request.predicate = NSPredicate(format: "isAccepted == NO")
            for item in try context.fetch(request) { context.delete(item) }

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
        }
    }

    func fetchPendingSuggestions() -> [RoutineSuggestion] {
        let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
        request.predicate = NSPredicate(format: "isAccepted == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "stepOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    @discardableResult
    func acceptSuggestions(_ suggestions: [RoutineSuggestion]) -> Bool {
        commit {
            for suggestion in suggestions {
                let request: NSFetchRequest<RoutineItem> = RoutineItem.fetchRequest()
                request.predicate = NSPredicate(format: "routineTime == %@ AND stepOrder == %d", suggestion.routineTime ?? "morning", suggestion.stepOrder)
                for duplicate in try context.fetch(request) { context.delete(duplicate) }

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
            }
        }
    }

    @discardableResult
    func dismissSuggestion(_ suggestion: RoutineSuggestion) -> Bool {
        commit { context.delete(suggestion) }
    }

    @discardableResult
    func dismissAllSuggestions() -> Bool {
        commit {
            let request: NSFetchRequest<RoutineSuggestion> = RoutineSuggestion.fetchRequest()
            request.predicate = NSPredicate(format: "isAccepted == NO")
            for item in try context.fetch(request) { context.delete(item) }
        }
    }
}

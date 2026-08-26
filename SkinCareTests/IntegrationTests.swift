//
//  IntegrationTests.swift
//  SkinCareTests
//
//  Created by Kerem Öztopuz on 22.05.2026.
//

import Testing
import Foundation
@testable import SkinCare
internal import CoreData

@Test @MainActor func testProfileSetupPersistsToCoreData() throws {
    let manager = LocalPersistenceManager(context: PersistenceController(inMemory: true).container.viewContext)
    let vm = ProfileSetupViewModel(persistenceManager: manager)
    vm.name = "Test User"
    vm.age = 30
    vm.gender = .female
    vm.skinType = .oily

    vm.handleContinue() // page 0 -> 1
    vm.handleContinue() // page 1 -> 2
    vm.handleContinue() // page 2 -> 3
    vm.handleContinue() // page 3 -> completeProfile()

    #expect(vm.didFinish)

    let profile = try #require(manager.fetchUserProfile())
    #expect(profile.name == "Test User")
    #expect(profile.skinType == "Oily")
    #expect(profile.gender == "Female")
    #expect(profile.ageRange == "30")
}

@Test @MainActor func testAnalysisScoringAndRecentsIntegration() {
    let manager = LocalPersistenceManager(context: PersistenceController(inMemory: true).container.viewContext)
    let engine = ScoringEngine()
    let score = engine.calculateScore(acne: 0.7, redness: 0.3, pigmentation: 0.0, hydration: 0.4, skinType: "oily")

    let olderDate = Date().addingTimeInterval(-86400 * 3)
    let newerDate = Date()

    manager.saveAnalysisRecord(
        condition: "Acne",
        confidence: 0.7,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        date: olderDate,
        inflammationScore: score.inflammationScore,
        oilinessScore: score.oilinessScore,
        overallScore: score.overallScore,
        acneScore: 0.7,
        eczemaScore: 0.0,
        hydrationScore: 40.0,
        imageData: nil
    )

    let score2 = engine.calculateScore(acne: 0.1, redness: 0.0, pigmentation: 0.0, hydration: 0.8, skinType: "oily")

    manager.saveAnalysisRecord(
        condition: "Healthy",
        confidence: 0.8,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        date: newerDate,
        inflammationScore: score2.inflammationScore,
        oilinessScore: score2.oilinessScore,
        overallScore: score2.overallScore,
        acneScore: 0.1,
        eczemaScore: 0.0,
        hydrationScore: 80.0,
        imageData: nil
    )

    // fetchAnalysisRecords sorts newest-first via its NSSortDescriptor.
    let records = manager.fetchAnalysisRecords()
    #expect(records.count == 2)
    #expect(records.first?.condition == "Healthy")
    #expect((records.first?.overallScore ?? 0) > (records.last?.overallScore ?? 0))
}

@Test @MainActor func testScoreMigrationBackfillsLegacyHydration() {
    let versionKey = "scoreSchemaVersion"
    let previousVersion = UserDefaults.standard.integer(forKey: versionKey)
    defer { UserDefaults.standard.set(previousVersion, forKey: versionKey) }
    UserDefaults.standard.set(0, forKey: versionKey)

    let manager = LocalPersistenceManager(context: PersistenceController(inMemory: true).container.viewContext)
    manager.saveAnalysisRecord(
        condition: "Acne",
        confidence: 0.5,
        wrinkleScore: 10.0,
        eyebagScore: 5.0,
        pigmentationScore: 5.0,
        date: Date(),
        inflammationScore: 0.0,
        oilinessScore: 0.0,
        overallScore: 0.0,
        acneScore: 50.0,
        eczemaScore: 10.0,
        // Records from before hydration was measured stored a flat 0.
        hydrationScore: 0.0,
        imageData: nil
    )

    manager.migrateScoresIfNeeded()

    let record = manager.fetchAnalysisRecords().first
    #expect(record?.hydrationScore == 50.0)
    #expect((record?.overallScore ?? 0) > 0)
}

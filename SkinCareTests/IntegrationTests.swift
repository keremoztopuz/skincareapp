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
    let score = engine.calculateScore(acne: 0.7, redness: 0.3, pigmentation: 0.0, skinType: "oily")

    let olderDate = Date().addingTimeInterval(-86400 * 3)
    let newerDate = Date()

    manager.saveAnalysisRecord(
        condition: "Acne",
        confidence: 0.7,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        date: olderDate,
        drynessScore: score.drynessScore,
        inflammationScore: score.inflammationScore,
        oilinessScore: score.oilinessScore,
        overallScore: score.overallScore,
        userFeedback: false,
        acneScore: 0.7,
        eczemaScore: 0.0,
        imageData: nil
    )

    let score2 = engine.calculateScore(acne: 0.1, redness: 0.0, pigmentation: 0.0, skinType: "oily")

    manager.saveAnalysisRecord(
        condition: "Healthy",
        confidence: 0.8,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        date: newerDate,
        drynessScore: score2.drynessScore,
        inflammationScore: score2.inflammationScore,
        oilinessScore: score2.oilinessScore,
        overallScore: score2.overallScore,
        userFeedback: false,
        acneScore: 0.1,
        eczemaScore: 0.0,
        imageData: nil
    )

    let records = manager.fetchAnalysisRecords()
    #expect(records.count == 2)

    let vm = RecentsViewModel()
    let sorted = vm.mergeSort(records)

    #expect(sorted.first?.condition == "Healthy")
    #expect(sorted.first?.overallScore ?? 0 > sorted.last?.overallScore ?? 0)
}

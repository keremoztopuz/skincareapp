//
//  IntegrationTests.swift
//  SkinCareTests
//
//  Created by Kerem Öztopuz on 22.05.2026.
//

import XCTest
import Testing
@testable import SkinCare
internal import CoreData

@Test @MainActor func testProfileSetupPersistsToCoreData() {
    let vm = ProfileSetupViewModel()
    vm.name = "Test User"
    vm.age = 30
    vm.gender = .female
    vm.skinType = .oily

    vm.handleContinue() // page 0 -> 1
    vm.handleContinue() // page 1 -> 2
    vm.handleContinue() // page 2 -> 3
    vm.handleContinue() // page 3 -> completeProfile()

    XCTAssertTrue(vm.didFinish)

    let profile = LocalPersistenceManager.shared.fetchUserProfile()
    XCTAssertNotNil(profile)
    XCTAssertEqual(profile?.name, "Test User")
    XCTAssertEqual(profile?.skinType, "Oily")
    XCTAssertEqual(profile?.gender, "Female")
    XCTAssertEqual(profile?.ageRange, "30")
}

@Test @MainActor func testAnalysisScoringAndRecentsIntegration() {
    let engine = ScoringEngine()
    let score = engine.calculateScore(acne: 0.7, redness: 0.3, psoriasis: 0.0, pigmentation: 0.0, hydration: 0.2, skinType: "oily")

    let olderDate = Date().addingTimeInterval(-86400 * 3)
    let newerDate = Date()

    LocalPersistenceManager.shared.saveAnalysisRecord(
        condition: "Acne",
        confidence: 0.7,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        hydrationScore: 0.2,
        date: olderDate,
        drynessScore: score.drynessScore,
        inflammationScore: score.inflammationScore,
        oilinessScore: score.oilinessScore,
        overallScore: score.overallScore,
        userFeedback: false,
        acneScore: 0.7,
        eczemaScore: 0.0,
        psoriasisScore: 0.0,
        imageData: nil
    )

    let score2 = engine.calculateScore(acne: 0.1, redness: 0.0, psoriasis: 0.0, pigmentation: 0.0, hydration: 0.8, skinType: "oily")

    LocalPersistenceManager.shared.saveAnalysisRecord(
        condition: "Healthy",
        confidence: 0.8,
        wrinkleScore: 0.0,
        eyebagScore: 0.0,
        pigmentationScore: 0.0,
        hydrationScore: 0.8,
        date: newerDate,
        drynessScore: score2.drynessScore,
        inflammationScore: score2.inflammationScore,
        oilinessScore: score2.oilinessScore,
        overallScore: score2.overallScore,
        userFeedback: false,
        acneScore: 0.1,
        eczemaScore: 0.0,
        psoriasisScore: 0.0,
        imageData: nil
    )

    let records = LocalPersistenceManager.shared.fetchAnalysisRecords()
    XCTAssertGreaterThanOrEqual(records.count, 2)

    let vm = RecentsViewModel()
    let sorted = vm.mergeSort(records)

    XCTAssertEqual(sorted.first?.condition, "Healthy")
    XCTAssertGreaterThan(sorted.first?.overallScore ?? 0, sorted.last?.overallScore ?? 0)

    let context = PersistenceController.shared.container.viewContext
    for record in records where record.condition == "Acne" || record.condition == "Healthy" {
        context.delete(record)
    }
    try? context.save()
}

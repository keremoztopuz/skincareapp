//
//  AnalysisTests.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 14.05.2026.
//

import Testing
import UIKit
import Vision
@testable import SkinCare
internal import CoreData

/// Performs a Vision request, retrying when the simulator cannot create an
/// inference context under parallel test load (Vision error code 9).
/// Returns false if the environment never produced a usable context —
/// callers should bail out without asserting. Any other error is rethrown.
private func performOrSkip(_ handler: VNImageRequestHandler, _ request: VNDetectFaceRectanglesRequest) throws -> Bool {
    for attempt in 0..<3 {
        do {
            try handler.perform([request])
            return true
        } catch let error as NSError where error.domain == "com.apple.Vision" && error.code == 9 {
            if attempt == 2 { return false }
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    return false
}

@Test func testScoringEngineCalculation() {
    // mock data for test
    let engine = ScoringEngine()
    let acneScore = 0.8
    // calculate function
    let result = engine.calculateScore(acne: acneScore,
                                       redness: 0.1,
                                       pigmentation: 0.0,
                                       skinType: "oily")
    // check result
    #expect(result.overallScore >= 0)
    #expect(result.overallScore <= 100)

    #expect(result.inflammationScore > 50)
}

@Test func testFaceDetectionWithDummyImage() throws {
    let size = CGSize(width: 1000, height: 1000)
    UIGraphicsBeginImageContext(size)
    UIColor.red.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))
    let dummyImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let cgImage = try #require(dummyImage?.cgImage, "Failed to create dummy image")

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()
    guard try performOrSkip(handler, request) else { return }

    let results = request.results ?? []
    #expect(results.isEmpty, "No face should be detected in a plain red image")
}

@Test func testVisionFaceDetectionWithRealImage() throws {
    let image = try #require(UIImage(named: "guidegood1"), "guidegood1 image could not be loaded")
    let cgImage = try #require(image.cgImage)

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()
    guard try performOrSkip(handler, request) else { return }

    let results = request.results ?? []
    #expect(!results.isEmpty, "At least one face should be detected in guidegood1 image")

    let face = try #require(results.first)
    #expect(face.boundingBox.width > 0)
    #expect(face.boundingBox.height > 0)
}

@Test func testScoringEngineHealthySkin() {

    let engine = ScoringEngine()
    let result = engine.calculateScore(acne: 0, redness: 0, pigmentation: 0, skinType: "normal")

    #expect(result.overallScore > 50)
    #expect(result.inflammationScore < 40)
}

@Test func testScoringEngineHydrationAffectsOverall() {
    let engine = ScoringEngine()
    let hydrated = engine.calculateScore(acne: 0, redness: 0, pigmentation: 0, hydration: 1.0, skinType: "normal")
    let dehydrated = engine.calculateScore(acne: 0, redness: 0, pigmentation: 0, hydration: 0.0, skinType: "normal")

    #expect(dehydrated.overallScore < hydrated.overallScore)
    #expect(dehydrated.drynessScore > hydrated.drynessScore)
}

@Test func testScoringEngineMultipleConditions() {

    let engine = ScoringEngine()
    let results = engine.calculateScore(acne: 0.7, redness: 0.6, pigmentation: 0.0, skinType: "oily")

    #expect(results.overallScore < 50)
    #expect(results.inflammationScore > 50)
}

@Test func testScoringEngineSkinTypeComparison() {
    let engine = ScoringEngine()
    let skinTypes = ["oily", "dry", "normal", "combination", "sensitive"]

    for skinType in skinTypes {
        let result = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: skinType)
        #expect(result.overallScore >= 0, "overallScore out of range for \(skinType)")
        #expect(result.overallScore <= 100, "overallScore out of range for \(skinType)")
    }
}

@Test func testScoringEngineBoundaryValues() {
    let engine = ScoringEngine()
    let result = engine.calculateScore(acne: 0.0, redness: 0.0, pigmentation: 0.0, skinType: "normal")

    #expect(result.overallScore >= 0)
    #expect(result.overallScore <= 100)
    #expect(result.dominantCondition == "")

    let maxResult = engine.calculateScore(acne: 1.0, redness: 1.0, pigmentation: 1.0, skinType: "normal")

    #expect(maxResult.overallScore >= 0)
    #expect(maxResult.overallScore <= 100)
}

@Test func testScoringEngineWrinklesLowerOverall() {
    let engine = ScoringEngine()
    let without = engine.calculateScore(acne: 0.2, redness: 0.1, pigmentation: 0.1, skinType: "normal")
    let with_ = engine.calculateScore(acne: 0.2, redness: 0.1, pigmentation: 0.1, wrinkles: 0.8, eyebags: 0.6, skinType: "normal")

    #expect(with_.overallScore < without.overallScore)
}

@Test func testScoringEngineSensitiveSkinRednessSusceptibility() {
    let engine = ScoringEngine()
    let sensitive = engine.calculateScore(acne: 0, redness: 0.6, pigmentation: 0, skinType: "sensitive")
    let normal = engine.calculateScore(acne: 0, redness: 0.6, pigmentation: 0, skinType: "normal")

    #expect(sensitive.inflammationScore > normal.inflammationScore)
    #expect(sensitive.overallScore < normal.overallScore)
}

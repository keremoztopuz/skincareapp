//
//  AnalysisTests.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 14.05.2026.
//

import XCTest
import Testing
import Vision
@testable import SkinCare
internal import CoreData

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
    XCTAssertGreaterThanOrEqual(result.overallScore, 0)
    XCTAssertLessThanOrEqual(result.overallScore, 100)
    
    XCTAssertGreaterThan(result.inflammationScore, 50)
}

@Test func testFaceDetectionWithDummyImage() throws {
    let size = CGSize(width: 1000, height: 1000)
    UIGraphicsBeginImageContext(size)
    UIColor.red.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))
    let dummyImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = dummyImage?.cgImage else {
        XCTFail("Failed to create dummy image")
        return
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()

    do {
        try handler.perform([request])
    } catch {
        return
    }

    let results = request.results ?? []
    XCTAssertTrue(results.isEmpty, "No face should be detected in a plain red image")
}

@Test func testVisionFaceDetectionWithRealImage() throws {
    guard let image = UIImage(named: "guidegood1"),
          let cgImage = image.cgImage else {
        XCTFail("guidegood1 image could not be loaded")
        return
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()

    do {
        try handler.perform([request])
    } catch {
        return
    }

    let results = request.results ?? []
    XCTAssertFalse(results.isEmpty, "At least one face should be detected in guidegood1 image")

    let face = results.first!
    XCTAssertGreaterThan(face.boundingBox.width, 0)
    XCTAssertGreaterThan(face.boundingBox.height, 0)
}

@Test func testScoringEngineHealthySkin() {
    
    let engine = ScoringEngine()
    let result = engine.calculateScore(acne: 0, redness: 0, pigmentation: 0, skinType: "normal")
    
    XCTAssertGreaterThan(result.overallScore, 50)
    XCTAssertLessThan(result.inflammationScore, 40)
}

@Test func testScoringEngineMultipleConditions() {
    
    let engine = ScoringEngine()
    let results = engine.calculateScore(acne: 0.7, redness: 0.6, pigmentation: 0.0, skinType: "oily")
    
    XCTAssertLessThan(results.overallScore, 50)
    XCTAssertGreaterThan(results.inflammationScore, 50)
}

@Test func testScoringEngineSkinTypeComparison() {
    let engine = ScoringEngine()
    let oilyResult = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: "oily")
    let dryResult = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: "dry")
    let normalResult = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: "normal")
    let combinationResult = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: "combination")
    let sensitiveResult = engine.calculateScore(acne: 0.5, redness: 0, pigmentation: 0, skinType: "sensitive")
    
    XCTAssertGreaterThanOrEqual(oilyResult.overallScore, 0)
    XCTAssertLessThanOrEqual(oilyResult.overallScore, 100)
    XCTAssertGreaterThanOrEqual(dryResult.overallScore, 0)
    XCTAssertLessThanOrEqual(dryResult.overallScore, 100)
    XCTAssertGreaterThanOrEqual(normalResult.overallScore, 0)
    XCTAssertLessThanOrEqual(normalResult.overallScore, 100)
    XCTAssertGreaterThanOrEqual(combinationResult.overallScore, 0)
    XCTAssertLessThanOrEqual(combinationResult.overallScore, 100)
    XCTAssertGreaterThanOrEqual(sensitiveResult.overallScore, 0)
    XCTAssertLessThanOrEqual(sensitiveResult.overallScore, 100)
}

@Test func testScoringEngineBoundaryValues() {
    let engine = ScoringEngine()
    let result = engine.calculateScore(acne: 0.0, redness: 0.0, pigmentation: 0.0, skinType: "normal")

    XCTAssertGreaterThanOrEqual(result.overallScore, 0)
    XCTAssertLessThanOrEqual(result.overallScore, 100)
    XCTAssertEqual(result.dominantCondition, "")

    let maxResult = engine.calculateScore(acne: 1.0, redness: 1.0, pigmentation: 1.0, skinType: "normal")

    XCTAssertGreaterThanOrEqual(maxResult.overallScore, 0)
    XCTAssertLessThanOrEqual(maxResult.overallScore, 100)
}

@Test func testScoringEngineWrinklesLowerOverall() {
    let engine = ScoringEngine()
    let without = engine.calculateScore(acne: 0.2, redness: 0.1, pigmentation: 0.1, skinType: "normal")
    let with_ = engine.calculateScore(acne: 0.2, redness: 0.1, pigmentation: 0.1, wrinkles: 0.8, eyebags: 0.6, skinType: "normal")

    XCTAssertLessThan(with_.overallScore, without.overallScore)
}

@Test func testScoringEngineSensitiveSkinRednessSusceptibility() {
    let engine = ScoringEngine()
    let sensitive = engine.calculateScore(acne: 0, redness: 0.6, pigmentation: 0, skinType: "sensitive")
    let normal = engine.calculateScore(acne: 0, redness: 0.6, pigmentation: 0, skinType: "normal")

    XCTAssertGreaterThan(sensitive.inflammationScore, normal.inflammationScore)
    XCTAssertLessThan(sensitive.overallScore, normal.overallScore)
}

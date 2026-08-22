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
    try handler.perform([request])

    let results = request.results ?? []
    #expect(results.isEmpty, "No face should be detected in a plain red image")
}

@Test func testVisionFaceDetectionWithRealImage() throws {
    let image = try #require(UIImage(named: "guidegood1"), "guidegood1 image could not be loaded")
    let cgImage = try #require(image.cgImage)

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()
    try handler.perform([request])

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

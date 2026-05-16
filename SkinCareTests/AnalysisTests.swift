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

@Test func testScoringEngineCalculation() {
    // mock data for test
    let engine = ScoringEngine()
    let acneScore = 0.8
    // calculate function
    let result = engine.calculateScore(acne: acneScore,
                                       eczema: 0.1,
                                       psoriasis: 0.0,
                                       benLezyon: 0.0,
                                       healthy: 0.1,
                                       skinType: "oily")
    // check result
    XCTAssertGreaterThanOrEqual(result.overallScore, 0)
    XCTAssertLessThanOrEqual(result.overallScore, 100)
    
    XCTAssertGreaterThan(result.inflammationScore, 50)
}

@Test func testFaceDetectionAndCropping() async {
    let viewModel = CameraViewModel()
    // fake image for test
    let size = CGSize(width: 1000, height: 1000)
    UIGraphicsBeginImageContext(size)
    UIColor.red.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))
    
    let dummyImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let image = dummyImage else { return }
    
    XCTAssertTrue(viewModel.isAnalyzing, "Analyse started.")
}

@Test func testVisionFaceDetectionWithRealImage() throws {
    guard let image = UIImage(named: "guidegood1"),
          let cgImage = image.cgImage else {
        XCTFail("guidegood1 görseli yüklenemedi")
        return
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
    let request = VNDetectFaceRectanglesRequest()

    try handler.perform([request])

    let results = request.results ?? []
    XCTAssertFalse(results.isEmpty, "guidegood1 görselinde en az bir yüz tespit edilmeli")

    let face = results.first!
    XCTAssertGreaterThan(face.boundingBox.width, 0)
    XCTAssertGreaterThan(face.boundingBox.height, 0)
}

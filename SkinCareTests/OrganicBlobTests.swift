//
//  OrganicBlobTests.swift
//  SkinCareTests
//

import Testing
import SwiftUI
@testable import SkinCare

private let rect = CGRect(x: 10, y: 20, width: 120, height: 60)

@Test func testBlobIsDeterministicPerSeed() {
    let a = OrganicBlobShape(seed: 42).path(in: rect)
    let b = OrganicBlobShape(seed: 42).path(in: rect)
    let c = OrganicBlobShape(seed: 43).path(in: rect)
    #expect(a.description == b.description)
    #expect(a.description != c.description)
}

@Test func testBlobStaysNearItsRect() {
    // Wobble tops out at 1.12 of the inscribed radius and the spline
    // interpolates its anchors, so the blob may lap over the rect edge but
    // never wander: a 15% inflation must contain it.
    let bounds = OrganicBlobShape(seed: 7).path(in: rect).boundingRect
    let allowed = rect.insetBy(dx: -rect.width * 0.15, dy: -rect.height * 0.15)
    #expect(allowed.contains(bounds))
}

@Test func testDegenerateRectDrawsNothing() {
    #expect(OrganicBlobShape(seed: 1).path(in: .zero).isEmpty)
    #expect(OrganicBlobShape(seed: 1, anchorCount: 2).path(in: rect).isEmpty)
}

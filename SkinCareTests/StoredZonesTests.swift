//
//  StoredZonesTests.swift
//  SkinCareTests
//

import Testing
import CoreGraphics
import Foundation
@testable import SkinCare

@Test func testStoredZonesRoundTrip() throws {
    let zones = StoredZones(
        crop: StoredZones.Rect(x: 0.2, y: 0.1, w: 0.5, h: 0.6),
        regions: [
            "acne": [StoredZones.Rect(x: 0.1, y: 0.2, w: 0.3, h: 0.25)],
            "redness": []
        ]
    )
    let data = try #require(zones.encoded())
    let decoded = try #require(StoredZones.decode(data))
    #expect(decoded == zones)
    #expect(StoredZones.decode(nil) == nil)
    #expect(StoredZones.decode(Data("junk".utf8)) == nil)
}

@Test func testAvailableKeysIgnoreEmptyRegionLists() {
    let zones = StoredZones(
        crop: .fullFrame,
        regions: ["acne": [StoredZones.Rect(x: 0, y: 0, w: 0.5, h: 0.5)], "redness": []]
    )
    #expect(zones.availableKeys == ["acne"])
}

@Test func testFrameRegionsComposeCropAndRegion() throws {
    // A crop occupying the middle of the frame; a region in the crop's
    // upper-left quarter must land inside the crop, scaled by its size.
    let zones = StoredZones(
        crop: StoredZones.Rect(x: 0.2, y: 0.1, w: 0.5, h: 0.6),
        regions: ["acne": [StoredZones.Rect(x: 0.1, y: 0.2, w: 0.4, h: 0.5)]]
    )
    let rect = try #require(zones.frameRegions(for: "acne").first)
    #expect(abs(rect.origin.x - (0.2 + 0.1 * 0.5)) < 1e-9)
    #expect(abs(rect.origin.y - (0.1 + 0.2 * 0.6)) < 1e-9)
    #expect(abs(rect.width - 0.4 * 0.5) < 1e-9)
    #expect(abs(rect.height - 0.5 * 0.6) < 1e-9)
    #expect(zones.frameRegions(for: "eyebags").isEmpty)
}

@Test func testFullFrameCropIsIdentity() throws {
    let region = StoredZones.Rect(x: 0.25, y: 0.4, w: 0.3, h: 0.2)
    let zones = StoredZones(crop: .fullFrame, regions: ["redness": [region]])
    let rect = try #require(zones.frameRegions(for: "redness").first)
    #expect(rect == CGRect(x: 0.25, y: 0.4, width: 0.3, height: 0.2))
}

@Test func testAspectFillTransform() {
    // A 100x200 image filling a 100x100 container: no scaling, vertically
    // centered, so the top corner maps above the container and the center
    // maps to the center. Points outside stay outside — clipping is the
    // photo's clip shape's job, not the mapper's.
    let transform = AspectFillMapper.transform(
        imageSize: CGSize(width: 100, height: 200),
        containerSize: CGSize(width: 100, height: 100)
    )
    #expect(CGPoint(x: 50, y: 100).applying(transform) == CGPoint(x: 50, y: 50))
    #expect(CGPoint(x: 0, y: 0).applying(transform) == CGPoint(x: 0, y: -50))

    // A wide image into a taller container scales by height and centers
    // horizontally: 200x100 into 100x100 -> scale 1, x offset -50.
    let wide = AspectFillMapper.transform(
        imageSize: CGSize(width: 200, height: 100),
        containerSize: CGSize(width: 100, height: 100)
    )
    #expect(CGPoint(x: 100, y: 50).applying(wide) == CGPoint(x: 50, y: 50))

    // Degenerate image sizes must not divide by zero.
    #expect(AspectFillMapper.transform(imageSize: .zero, containerSize: CGSize(width: 10, height: 10)) == .identity)
}

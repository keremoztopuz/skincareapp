//
//  StoredZones.swift
//  SkinCare
//

import CoreGraphics
import Foundation

/// Where the analysed conditions sit on the stored photo.
///
/// Two coordinate spaces meet here. The model's regions are normalized to the
/// face crop that was uploaded; the record stores the full frame. `crop` is
/// that crop's rectangle normalized to the full frame, so `frameRegions(for:)`
/// can compose the two without either side knowing about the other. All
/// values are 0-1 with the origin at the top left.
struct StoredZones: Codable, Equatable {
    struct Rect: Codable, Equatable {
        let x: Double
        let y: Double
        let w: Double
        let h: Double

        /// The whole frame — the crop of a scan where face detection found
        /// nothing to crop.
        static let fullFrame = Rect(x: 0, y: 0, w: 1, h: 1)
    }

    /// The uploaded face crop, normalized to the full stored frame. When face
    /// detection found nothing the full frame itself was uploaded, and this
    /// is (0, 0, 1, 1).
    let crop: Rect

    /// Per condition key ("acne", "redness", …), regions normalized to the
    /// crop, exactly as the proxy returned them.
    let regions: [String: [Rect]]

    /// Condition keys that actually have something to draw.
    var availableKeys: Set<String> {
        Set(regions.filter { !$0.value.isEmpty }.keys)
    }

    /// One condition's regions in full-frame normalized coordinates.
    func frameRegions(for key: String) -> [CGRect] {
        (regions[key] ?? []).map { rect in
            CGRect(
                x: crop.x + rect.x * crop.w,
                y: crop.y + rect.y * crop.h,
                width: rect.w * crop.w,
                height: rect.h * crop.h
            )
        }
    }

    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }

    static func decode(_ data: Data?) -> StoredZones? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(StoredZones.self, from: data)
    }
}

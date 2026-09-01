//
//  MockScanSeeder.swift
//  SkinCare
//

#if DEBUG
import Foundation
import UIKit

/// Two ready-made analysis records, so the history, comparison and result
/// screens can be exercised without a camera or a live analysis proxy.
///
/// Debug builds only, and even there it does nothing unless the launch
/// argument asks for it:
///
///     xcrun simctl launch booted com.keremoztopuz.SkinCare -seedMockScans YES
///
/// or Product > Scheme > Edit Scheme > Run > Arguments > `-seedMockScans YES`.
///
/// Leaving that argument set in the scheme is harmless: the seed only runs
/// against an empty history, so a run never piles two more records onto the
/// list. Delete the app (or its records) to seed again.
enum MockScanSeeder {
    private static let launchKey = "seedMockScans"

    static func seedIfRequested(into manager: LocalPersistenceManager = .shared) {
        guard UserDefaults.standard.bool(forKey: launchKey) else { return }

        guard manager.fetchAnalysisRecords().isEmpty else { return }

        seed(into: manager)
    }

    /// A before and an after, deliberately: the older scan is the worse one, so
    /// the history list has a trend to draw and the comparison screen has an
    /// improvement to show.
    ///
    /// The two also take different paths through the recommendation engine. The
    /// older one names a condition (acne clears the 66 naming threshold), so the
    /// result screen fetches condition-specific products. The newer one clears
    /// every `ConditionDetector` threshold — including the derived inflammation
    /// one — so it falls to the general-care list instead.
    static func seed(into manager: LocalPersistenceManager = .shared) {
        let skinType = manager.fetchUserProfile()?.skinType?.lowercased() ?? "normal"

        save(
            condition: "Acne",
            acne: 68, redness: 44, pigmentation: 33,
            wrinkles: 20, eyebags: 26, hydration: 52,
            daysAgo: 6,
            skinType: skinType,
            // The camera guide's own bundled portrait plus hand-placed
            // regions, so the zone overlay can be exercised with no camera
            // and no live proxy. The newer record stays photo-less on
            // purpose — the unselectable path has to stay visible too.
            imageData: UIImage(named: "guidegood1")?.jpegData(compressionQuality: 0.5),
            zonesData: mockZones.encoded(),
            into: manager
        )

        save(
            condition: "Healthy",
            acne: 15, redness: 12, pigmentation: 20,
            wrinkles: 14, eyebags: 18, hydration: 74,
            daysAgo: 0,
            skinType: skinType,
            into: manager
        )
    }

    /// Boxes sitting on the guidegood1 face (its face spans roughly
    /// x 0.40-0.68, y 0.22-0.62 of the frame). The wrinkles boxes are real
    /// output from a live Gemini probe of this very image; the others are
    /// hand-placed in the same style. Crop is the full frame, matching a
    /// scan where face detection found nothing to crop.
    private static var mockZones: StoredZones {
        StoredZones(
            crop: StoredZones.Rect.fullFrame,
            regions: [
                "acne": [
                    StoredZones.Rect(x: 0.46, y: 0.26, w: 0.14, h: 0.07),
                    StoredZones.Rect(x: 0.50, y: 0.55, w: 0.10, h: 0.06)
                ],
                "redness": [
                    StoredZones.Rect(x: 0.42, y: 0.42, w: 0.08, h: 0.08),
                    StoredZones.Rect(x: 0.58, y: 0.42, w: 0.09, h: 0.08)
                ],
                "wrinkles": [
                    StoredZones.Rect(x: 0.40, y: 0.46, w: 0.08, h: 0.04),
                    StoredZones.Rect(x: 0.50, y: 0.45, w: 0.08, h: 0.04),
                    StoredZones.Rect(x: 0.40, y: 0.35, w: 0.10, h: 0.05)
                ]
            ]
        )
    }

    /// Severities are stored on the 0-100 scale and handed to the engine on the
    /// 0-1 one, exactly as `CameraViewModel` does — a mock record that skipped
    /// the engine would sit on a different scale than every real scan and the
    /// trend chart would show a phantom jump between them.
    private static func save(
        condition: String,
        acne: Double,
        redness: Double,
        pigmentation: Double,
        wrinkles: Double,
        eyebags: Double,
        hydration: Double,
        daysAgo: Double,
        skinType: String,
        imageData: Data? = nil,
        zonesData: Data? = nil,
        into manager: LocalPersistenceManager
    ) {
        let scores = ScoringEngine().calculateScore(
            acne: acne / 100,
            redness: redness / 100,
            pigmentation: pigmentation / 100,
            wrinkles: wrinkles / 100,
            eyebags: eyebags / 100,
            hydration: hydration / 100,
            skinType: skinType
        )

        manager.saveAnalysisRecord(
            condition: condition,
            confidence: max(acne, redness) / 100.0,
            wrinkleScore: wrinkles,
            eyebagScore: eyebags,
            pigmentationScore: pigmentation,
            date: Date(timeIntervalSinceNow: -daysAgo * 86_400),
            inflammationScore: scores.inflammationScore,
            oilinessScore: scores.oilinessScore,
            overallScore: scores.overallScore,
            acneScore: acne,
            eczemaScore: redness,
            hydrationScore: hydration,
            imageData: imageData,
            zonesData: zonesData
        )
    }
}
#endif

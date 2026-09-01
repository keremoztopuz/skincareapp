import Foundation

/// Turns a record's raw severities into the catalogue's condition keys.
///
/// `AnalysisRecord.condition` cannot do this job. It is a display name, and
/// the camera flow only ever produces three of them — "Acne", "Redness" or
/// "Healthy" — so looking products up by that string reaches at most two of
/// the five classes, and on a typical scan asks the catalogue for "healthy",
/// which has no row in the `conditions` table and comes back empty.
///
/// The five keys returned here are exactly the five in that table:
/// `acne`, `redness`, `wrinkles`, `eyebags`, `pigmentation`.
enum ConditionDetector {

    /// The conditions a record is bad enough to act on, worst first.
    ///
    /// The weight is the severity normalized to 0-1, so a caller can sum the
    /// weights of a product that answers more than one condition and rank on
    /// the total.
    static func activeConditions(from record: AnalysisRecord) -> [(key: String, weight: Double)] {
        var conditions: [(key: String, weight: Double)] = []

        // Raw scores are stored on a 0-100 scale; normalize to 0-1 so the
        // skin-type adjustment in RoutineEngine.rankProducts stays meaningful.
        if record.acneScore > 35 { conditions.append(("acne", record.acneScore / 100.0)) }
        if record.eczemaScore > 35 { conditions.append(("redness", record.eczemaScore / 100.0)) }
        if record.pigmentationScore > 35 { conditions.append(("pigmentation", record.pigmentationScore / 100.0)) }
        if record.wrinkleScore > 30 { conditions.append(("wrinkles", record.wrinkleScore / 100.0)) }
        if record.eyebagScore > 30 { conditions.append(("eyebags", record.eyebagScore / 100.0)) }

        // Low hydration routes to barrier products, which the catalogue files
        // under the "redness" key — the conditions table has no dryness row.
        if record.hydrationScore < 45.0 && !conditions.contains(where: { $0.key == "redness" }) {
            conditions.append(("redness", (100.0 - record.hydrationScore) / 100.0))
        }
        if record.inflammationScore > 50.0 && !conditions.contains(where: { $0.key == "acne" }) {
            conditions.append(("acne", record.inflammationScore / 100.0))
        }

        return conditions.sorted { $0.weight > $1.weight }
    }

    /// What to offer when nothing crossed a threshold: the steps every routine
    /// has regardless of condition. Used to fill a section that would
    /// otherwise be empty on genuinely clear skin.
    static let generalCareProductTypes = ["cleanser", "moisturizer", "sunscreen"]
}

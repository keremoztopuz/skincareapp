//
//  ModelCalibration.swift
//  SkinCare
//

import Foundation

/// Calibration constants measured on the model's validation split.
///
/// The on-device classifier emits four raw logits in this order. Temperature
/// and per-class thresholds come from `calibrate.py` in the training repo and
/// are regenerated whenever the model is retrained — keep them in sync with
/// `outputs/model/temperature.json` and `outputs/model/thresholds.json`.
enum ModelCalibration {
    /// Output index of each class in the `scores` tensor.
    enum Index {
        static let acne = 0
        static let redness = 1   // trained as "Eczema"
        static let eyebags = 2
        static let wrinkles = 3
    }

    /// Fitted on validation NLL. Values below 1 sharpen the logits; the model
    /// is underconfident, so this widens the score distribution instead of
    /// collapsing it toward 50 the way the previous hand-picked 1.8 did.
    static let temperature = 0.6742

    /// Per-class probability cutoffs that maximize precision-weighted F-beta.
    static let acneThreshold = 0.66
    static let rednessThreshold = 0.62
    static let eyebagsThreshold = 0.68
    static let wrinklesThreshold = 0.45

    /// Converts a raw logit to the 0-100 score shown in the UI.
    static func score(fromLogit logit: Double) -> Double {
        let probability = 1.0 / (1.0 + exp(-logit / temperature))
        return min(max(probability * 100.0, 1.0), 99.0)
    }
}

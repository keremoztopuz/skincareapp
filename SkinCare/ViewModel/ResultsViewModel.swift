//
//  ResultsViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI
internal import Combine

class ResultsViewModel: ObservableObject {
    @Published var record: AnalysisRecord?
    @Published var recommendation: [String] = []
    @Published var recommendProduct: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// True when the screen shows a stored record from history. Routine
    /// suggestions belong to a fresh scan only — regenerating them on every
    /// history visit re-creates suggestion rows and inflates the badge on
    /// Home.
    private let isHistorical: Bool

    init(record: AnalysisRecord?, isHistorical: Bool = false) {
        self.record = record
        self.isHistorical = isHistorical
        Task {
            await generateRecommendations()
        }
    }

    //MARK: Personalized recommendations algorithm

    @MainActor
    func generateRecommendations() async {
        guard let condition = record?.condition else {
            recommendation = [String(localized: "recommendation_keep_hydrated")]
            // No record, no products: leave isLoading false so the view can
            // show its empty state instead of a spinner that never resolves.
            return
        }

        isLoading = true
        
        // simple text recommendation logic (could also come from the catalogue)
        switch condition.lowercased() {
        case "acne":
            recommendation = [String(localized: "recommendation_salicylic_cleanser")]
        case "redness", "eczema":
            recommendation = [
                String(localized: "recommendation_centella"),
                String(localized: "recommendation_avoid_extreme_temperatures")
            ]
        default:
            recommendation = [String(localized: "recommendation_consult_dermatologist")]
        }
        
        await fetchRecommendedProducts()

        if let record = self.record, !isHistorical {
            let skinType = LocalPersistenceManager.shared.fetchUserProfile()?.skinType ?? SkinType.normal.rawValue
            let suggestions = await RoutineEngine.shared.generateRoutine(from: record, skinType: skinType)
            if !suggestions.isEmpty {
                LocalPersistenceManager.shared.saveSuggestions(suggestions)
            }
        }

        isLoading = false
    }

    /// Product fetch on its own, so a retry does not re-run the routine
    /// suggestion pass and duplicate the suggestions of a fresh scan.
    @MainActor
    func fetchRecommendedProducts() async {
        guard let condition = record?.condition else { return }
        errorMessage = nil
        do {
            self.recommendProduct = try await CatalogueService.shared.fetchRecommendedProducts(for: condition)
        } catch {
            self.errorMessage = AppStrings.loadFailureMessage(for: error)
            AppLog.error("Recommended products fetch failed", error)
        }
    }
}

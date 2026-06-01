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
    
    init(record: AnalysisRecord?) {
        self.record = record
        Task {
            await generateRecommendations()
        }
    }
    
    //MARK: Personalized recommendations algorithm
    
    @MainActor
    func generateRecommendations() async {
        guard let condition = record?.condition else {
            recommendation = [String(localized: "recommendation_keep_hydrated")]
            // Default products if no condition
            return
        }
        
        isLoading = true
        
        // simple text recommendation logic (could also be in Supabase)
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
        
        do {
            self.recommendProduct = try await SupabaseService.shared.fetchRecommendedProducts(for: condition)
        } catch {
            print("Failed to fetch recommended products: \(error.localizedDescription)")
        }

        if let record = self.record {
            let skinType = LocalPersistenceManager.shared.fetchUserProfile()?.skinType ?? SkinType.normal.rawValue
            let suggestions = await RoutineEngine.shared.generateRoutine(from: record, skinType: skinType)
            if !suggestions.isEmpty {
                LocalPersistenceManager.shared.saveSuggestions(suggestions)
            }
        }

        isLoading = false
    }
}

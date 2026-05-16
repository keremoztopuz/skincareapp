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
            recommendation = ["Keep your skin hydrated and protected."]
            // Default products if no condition
            return
        }
        
        isLoading = true
        
        // simple text recommendation logic (could also be in Supabase)
        switch condition {
        case "Acne":
            recommendation = ["Use salicylic acid cleanser."]
        case "Redness":
            recommendation = ["Use soothing products with Centella.", "Avoid extreme temperatures."]
        default:
            recommendation = ["Consult a dermatologist for a tailored routine."]
        }
        
        do {
            self.recommendProduct = try await SupabaseService.shared.fetchRecommendedProducts(for: condition)
        } catch {
            print("Failed to fetch recommended products: \(error.localizedDescription)")
            // Fallback or empty state
        }
        
        isLoading = false
    }
}

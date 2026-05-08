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
    
    init(record: AnalysisRecord?) {
        self.record = record
        generateRecommendations()
    }
    
    //MARK: Personalized recommendations algorithm
    
    func generateRecommendations() {
        // algorithm will be there
        
        guard let condition = record?.condition else {
            recommendation = ["Keep your skin hydrated and protected."]
            recommendProduct = [
                Product(id: UUID(), name: "CeraVe Cleanser", category: "Face Cleanser", imageName: "product1"),
                Product(id: UUID(), name: "The Ordinary Niacinamide", category: "Serum", imageName: "product3")
            ]
            return
        }
        
        // simple match up for now
        switch condition {
        case "Acne":
            recommendation = ["Use salicylic acid cleanser."]
            recommendProduct = [
                Product(id: UUID(), name: "CeraVe Cleanser", category: "Face Cleanser", imageName: "product1"),
                Product(id: UUID(), name: "The Ordinary Niacinamide", category: "Serum", imageName: "product3")
            ]
        case "Eczema":
            recommendation = ["Use ceramide-rich creams.", "Avoid hot showers."]
            recommendProduct = [
                Product(id: UUID(), name: "Bioderma Atoderm", category: "Moisturizer", imageName: "product5"),
                Product(id: UUID(), name: "La Roche-Posay SPF", category: "Sunscreen", imageName: "product2")
            ]
        default:
            recommendation = ["Consult a dermatologist for a tailored routine."]
            recommendProduct = []
        }
    }
}

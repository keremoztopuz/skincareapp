//
//  HomeViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 20.04.2026.
//

import Foundation
import SwiftUI
internal import CoreData
internal import Combine

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var articles: [Articles] = []
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Average Statistics
    @Published var avgOverallScore: Int = 0
    @Published var avgDryness: Int = 0
    @Published var avgOiliness: Int = 0
    @Published var avgInflammation: Int = 0

    // Routine Summary
    @Published var routineStepNames: [String] = []
    @Published var routineItemCount: Int = 0
    @Published var hasPendingSuggestions: Bool = false

    init() {
        fetchNames()
        fetchStatistics()
        fetchRoutineSummary()

        Task {
            await fetchAllCloudData()
        }
    }
    
    @MainActor
    func fetchAllCloudData() async {
        guard products.isEmpty && articles.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let fetchedProducts = SupabaseService.shared.fetchProducts()
            async let fetchedArticles = SupabaseService.shared.fetchArticles()

            let (p, a) = try await (fetchedProducts, fetchedArticles)

            self.products = p
            self.articles = a
        } catch {
            self.errorMessage = "Internet connection required for products and articles."
            print("Supabase error: \(error)")
        }

        isLoading = false
    }
    
    func fetchStatistics() {
        let records = LocalPersistenceManager.shared.fetchAnalysisRecords()
        
        guard !records.isEmpty else { return }
        
        let count = Double(records.count)
        let totalOverall = records.reduce(0.0) { $0 + $1.overallScore }
        let totalDryness = records.reduce(0.0) { $0 + $1.drynessScore }
        let totalOiliness = records.reduce(0.0) { $0 + $1.oilinessScore }
        let totalInflammation = records.reduce(0.0) { $0 + $1.inflammationScore }
        
        DispatchQueue.main.async {
            self.avgOverallScore = Int(totalOverall / count)
            self.avgDryness = Int(totalDryness / count)
            self.avgOiliness = Int(totalOiliness / count)
            self.avgInflammation = Int(totalInflammation / count)
        }
    }
    
    func fetchRoutineSummary() {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeKey = hour < 18 ? "morning" : "evening"
        let items = LocalPersistenceManager.shared.fetchRoutineItems(for: timeKey)
        routineStepNames = items.sorted(by: { $0.stepOrder < $1.stepOrder }).compactMap {
            $0.productType?.replacingOccurrences(of: "_", with: " ").capitalized
        }
        routineItemCount = items.count
        hasPendingSuggestions = !LocalPersistenceManager.shared.fetchPendingSuggestions().isEmpty
    }

    func fetchNames() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        if let profile = profile {
            self.userName = profile.name ?? ""
            print("--- CORE DATA DEBUG ---")
            print("User Name: \(profile.name ?? "No Name")")
            print("Skin Type: \(profile.skinType ?? "No Type")")
            print("Gender: \(profile.gender ?? "No Gender")")
            print("-----------------------")
        } else {
            print("--- CORE DATA DEBUG ---")
            print("No User Profile found in Core Data.")
            print("-----------------------")
        }
    }
}

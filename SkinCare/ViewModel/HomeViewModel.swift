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

struct ScoreTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct RoutineStepDisplay: Identifiable {
    let id: UUID
    let typeName: String
    let productName: String?
    let isCompleted: Bool
}

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var articles: [Articles] = []
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Average Statistics
    @Published var avgOverallScore: Int = 0
    @Published var avgHydration: Int = 0
    @Published var avgOiliness: Int = 0
    @Published var avgInflammation: Int = 0

    // Overall score trend, oldest first, capped to the last 10 scans.
    @Published var scoreTrend: [ScoreTrendPoint] = []

    // Routine Summary
    @Published var routineSteps: [RoutineStepDisplay] = []
    @Published var pendingSuggestionCount: Int = 0

    var completedStepCount: Int { routineSteps.filter(\.isCompleted).count }

    /// Single source for the morning/evening switch, shared with the view.
    var routineTimeKey: String {
        Calendar.current.component(.hour, from: Date()) < 18 ? "morning" : "evening"
    }

    init() {
        // Local data is loaded from the view's onAppear, which also fires on
        // first appearance — fetching here too just doubled the work.
        Task {
            await fetchAllCloudData()
        }
    }
    
    @MainActor
    func fetchAllCloudData() async {
        // Only concurrency is guarded. An "already loaded" guard used to sit
        // here too, which made the retry button a no-op and left the first
        // snapshot on screen for the rest of the process lifetime.
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let fetchedProducts = SupabaseService.shared.fetchProducts()
            async let fetchedArticles = SupabaseService.shared.fetchArticles()

            let (p, a) = try await (fetchedProducts, fetchedArticles)

            self.products = p
            self.articles = a
        } catch {
            self.errorMessage = AppStrings.loadFailureMessage(for: error)
            AppLog.error("Home cloud fetch failed", error)
        }

        isLoading = false
    }
    
    func fetchStatistics() {
        let records = LocalPersistenceManager.shared.fetchAnalysisRecords()
        
        guard !records.isEmpty else { return }
        
        let count = Double(records.count)
        let totalOverall = records.reduce(0.0) { $0 + $1.overallScore }
        let totalHydration = records.reduce(0.0) { $0 + $1.hydrationScore }
        let totalOiliness = records.reduce(0.0) { $0 + $1.oilinessScore }
        let totalInflammation = records.reduce(0.0) { $0 + $1.inflammationScore }
        
        let trend = records
            .compactMap { record -> ScoreTrendPoint? in
                guard let date = record.date else { return nil }
                return ScoreTrendPoint(date: date, score: record.overallScore)
            }
            .sorted { $0.date < $1.date }
            .suffix(10)

        DispatchQueue.main.async {
            self.avgOverallScore = Int(totalOverall / count)
            self.avgHydration = Int(totalHydration / count)
            self.avgOiliness = Int(totalOiliness / count)
            self.avgInflammation = Int(totalInflammation / count)
            self.scoreTrend = Array(trend)
        }
    }
    
    func fetchRoutineSummary() {
        let timeKey = routineTimeKey
        let items = LocalPersistenceManager.shared.fetchRoutineItems(for: timeKey)
        let completed = RoutineCompletionStore.shared.completedIDs(time: timeKey)
        routineSteps = items.sorted(by: { $0.stepOrder < $1.stepOrder }).compactMap { item in
            guard let id = item.id, let type = item.productType else { return nil }
            return RoutineStepDisplay(
                id: id,
                typeName: AppStrings.localizedProductType(type),
                productName: item.productName,
                isCompleted: completed.contains(id)
            )
        }
        pendingSuggestionCount = LocalPersistenceManager.shared.fetchPendingSuggestions().count
    }

    func fetchNames() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        self.userName = profile?.name ?? ""
    }
}

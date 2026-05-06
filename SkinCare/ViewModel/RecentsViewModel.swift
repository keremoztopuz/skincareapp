//
//  RecentsViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 6.05.2026.
//

import Foundation
import SwiftUI
internal import Combine
internal import CoreData

class RecentsViewModel: ObservableObject {
    @Published var records: [AnalysisRecord] = []
    @Published var selectedFilter: String = "All Time"
    @AppStorage("isPremium") var isPremium: Bool = false
    
    init() {
        fetchRecords()
    }
    
    func fetchRecords() {
        records = LocalPersistenceManager.shared.fetchAnalysisRecords()

        // TEST: preview için mock data — sonra sil
        if records.isEmpty {
            let ctx = PersistenceController.shared.container.viewContext
            let r1 = AnalysisRecord(context: ctx)
            r1.condition = "Acne"
            r1.date = Date()
            r1.overallScore = 72
            r1.drynessScore = 45
            r1.inflammationScore = 68
            r1.oilinessScore = 55

            let r2 = AnalysisRecord(context: ctx)
            r2.condition = "Eczema"
            r2.date = Calendar.current.date(byAdding: .day, value: -3, to: Date())
            r2.overallScore = 58
            r2.drynessScore = 80
            r2.inflammationScore = 42
            r2.oilinessScore = 30

            records = [r1, r2]
        }
    }
    
}

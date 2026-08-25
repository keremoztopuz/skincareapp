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

enum RecordFilter: CaseIterable {
    case allTime
    case thisWeek
    case thisMonth

    var localizedTitle: String {
        switch self {
        case .allTime: return AppStrings.allTime
        case .thisWeek: return AppStrings.thisWeek
        case .thisMonth: return AppStrings.thisMonth
        }
    }
}

class RecentsViewModel: ObservableObject {
    @Published var records: [AnalysisRecord] = []
    @Published var lockedRecords: [AnalysisRecord] = []
    @Published var selectedFilter: RecordFilter = .allTime {
        didSet { fetchRecords() }
    }

    /// Every record, newest first, unfiltered and untruncated — the delta
    /// chips compare against the true previous scan, not the previous row
    /// of whatever filter happens to be active.
    private var allRecords: [AnalysisRecord] = []

    // No init-time fetch: the view's onAppear fires on first appearance too,
    // and fetching here as well just doubled the work.

    /// How much history a free user sees. Distinct from the monthly scan
    /// quota, which happens to share the same value — the two policies must
    /// be tunable independently.
    let freeHistoryLimit = 5
    var isPremium: Bool { SubscriptionManager.shared.isPremium }

    func fetchRecords() {
        // fetchAnalysisRecords already sorts newest-first via its
        // NSSortDescriptor; no client-side re-sort needed.
        allRecords = LocalPersistenceManager.shared.fetchAnalysisRecords()
        let filtered = applyFilter(allRecords)
        if isPremium {
            self.records = filtered
            self.lockedRecords = []
        } else {
            self.records = Array(filtered.prefix(freeHistoryLimit))
            self.lockedRecords = Array(filtered.dropFirst(freeHistoryLimit).prefix(3))
        }
    }

    /// Change in overall score against the chronologically previous scan,
    /// or nil for the oldest record.
    func delta(for record: AnalysisRecord) -> Double? {
        guard let index = allRecords.firstIndex(of: record),
              index + 1 < allRecords.count else { return nil }
        return record.overallScore - allRecords[index + 1].overallScore
    }

    private func applyFilter(_ records: [AnalysisRecord]) -> [AnalysisRecord] {
        guard selectedFilter != .allTime else { return records }
        let calendar = Calendar.current
        let now = Date()
        let granularity: Calendar.Component = selectedFilter == .thisWeek ? .weekOfYear : .month
        return records.filter { record in
            guard let date = record.date else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: granularity)
        }
    }

    func deleteRecord(_ record: AnalysisRecord) {
        LocalPersistenceManager.shared.deleteAnalysisRecord(record)
        fetchRecords()
    }

}

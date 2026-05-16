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
    @Published var lockedRecords: [AnalysisRecord] = []
    @Published var selectedFilter: String = "This Week"

    init() {
        fetchRecords()
    }

    var freeLimit: Int { SubscriptionManager.shared.freeMonthlyLimit }
    var isPremium: Bool { SubscriptionManager.shared.isPremium }

    func fetchRecords() {
        let fetched = LocalPersistenceManager.shared.fetchAnalysisRecords()
        let sorted  = mergeSort(fetched)
        if isPremium {
            self.records = sorted
            self.lockedRecords = []
        } else {
            self.records = Array(sorted.prefix(freeLimit))
            self.lockedRecords = Array(sorted.dropFirst(freeLimit).prefix(3))
        }
    }

    var hasLockedRecords: Bool {
        !lockedRecords.isEmpty
    }
    
    // MARK: - Merge Sort Implementation (Stable, O(n log n))
    func mergeSort(_ array: [AnalysisRecord]) -> [AnalysisRecord] {
        guard array.count > 1 else { return array }
        
        let middle = array.count / 2
        let left = mergeSort(Array(array[0..<middle]))
        let right = mergeSort(Array(array[middle..<array.count]))
        
        return merge(left, right)
    }
    
    func merge(_ left: [AnalysisRecord], _ right: [AnalysisRecord]) -> [AnalysisRecord] {
        var result: [AnalysisRecord] = []
        var i = 0
        var j = 0
        
        while i < left.count && j < right.count {
            if (left[i].date ?? Date()) > (right[j].date ?? Date()) {
                result.append(left[i])
                i += 1
            } else {
                result.append(right[j])
                j += 1
            }
        }
        
        while i < left.count {
            result.append(left[i])
            i += 1
        }
        while j < right.count {
            result.append(right[j])
            j += 1
        }
        return result
    }
}

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
        let unsorted = LocalPersistenceManager.shared.fetchAnalysisRecords()
        records = mergeSort(unsorted)

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
    
    func mergeSort(_ array: [AnalysisRecord]) -> [AnalysisRecord] {
        // if array has 1 or 0 index its already sorted
        if array.count <= 1 {
            return array
        }
        // split half
        let mid = array.count / 2
        let left = Array(array[0..<mid])
        let right = Array(array[mid..<array.count])
        // order recursively
        let sortedLeft = mergeSort(left)
        let sortedRight = mergeSort(right)
        
        return merge(sortedLeft, sortedRight)
    }
    
    func merge(_ left: [AnalysisRecord], _ right: [AnalysisRecord]) -> [AnalysisRecord] {
        var result: [AnalysisRecord] = []
        var i = 0 // left array pointer
        var j = 0 // right array pointer
        
        // take the lowest from two array
        while i < left.count && j < right.count {
            if left[i].overallScore >= right[j].overallScore {
                result.append(left[i])
                i += 1
            } else {
                result.append(right[j])
                j += 1
            }
        }
        // add lasts
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

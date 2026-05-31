import Foundation
import SwiftUI
internal import CoreData
internal import Combine

class RoutineViewModel: ObservableObject {
    @Published var morningItems: [RoutineItem] = []
    @Published var eveningItems: [RoutineItem] = []
    @Published var pendingSuggestions: [RoutineSuggestion] = []
    @Published var isLoading: Bool = false
    @Published var showAddProduct: Bool = false
    @Published var selectedRoutineTime: String = "morning"
    @Published var addingStepOrder: Int16 = 0
    @Published var addingProductType: String = ""

    private let manager = LocalPersistenceManager.shared

    init() {
        loadRoutine()
    }

    func loadRoutine() {
        morningItems = manager.fetchRoutineItems(for: "morning")
        eveningItems = manager.fetchRoutineItems(for: "evening")
        pendingSuggestions = manager.fetchPendingSuggestions()
    }

    func acceptSuggestion(_ suggestion: RoutineSuggestion) {
        manager.acceptSuggestion(suggestion)
        loadRoutine()
    }

    func dismissSuggestion(_ suggestion: RoutineSuggestion) {
        manager.dismissSuggestion(suggestion)
        pendingSuggestions = manager.fetchPendingSuggestions()
    }

    func acceptAllSuggestions() {
        for suggestion in pendingSuggestions {
            manager.acceptSuggestion(suggestion)
        }
        loadRoutine()
    }

    func dismissAllSuggestions() {
        manager.dismissAllSuggestions()
        loadRoutine()
    }

    func removeItem(_ item: RoutineItem) {
        manager.deleteRoutineItem(item)
        loadRoutine()
    }

    func addProductManually(product: Product, routineTime: String, stepOrder: Int16) {
        let existing = routineTime == "morning" ? morningItems : eveningItems
        if let duplicate = existing.first(where: { $0.stepOrder == stepOrder }) {
            manager.deleteRoutineItem(duplicate)
        }

        manager.saveRoutineItem(
            productId: product.id,
            productName: product.name,
            productBrand: product.brand,
            productImageUrl: product.imageUrl,
            productType: product.productType ?? "",
            routineTime: routineTime,
            stepOrder: stepOrder,
            isManuallyAdded: true
        )
        loadRoutine()
    }

    var currentItems: [RoutineItem] {
        selectedRoutineTime == "morning" ? morningItems : eveningItems
    }

    struct RoutineStep {
        let order: Int16
        let label: String
        let icon: String
        let productTypes: [String]
    }

    var currentSteps: [RoutineStep] {
        if selectedRoutineTime == "morning" {
            return [
                RoutineStep(order: 0, label: "Cleanser", icon: "drop.fill", productTypes: ["cleanser"]),
                RoutineStep(order: 1, label: "Serum", icon: "flask.fill", productTypes: ["serum"]),
                RoutineStep(order: 3, label: "Moisturizer", icon: "humidity.fill", productTypes: ["moisturizer"]),
                RoutineStep(order: 4, label: "Sunscreen", icon: "sun.max.fill", productTypes: ["sunscreen"])
            ]
        } else {
            return [
                RoutineStep(order: 0, label: "Cleanser", icon: "drop.fill", productTypes: ["cleanser"]),
                RoutineStep(order: 1, label: "Treatment", icon: "cross.vial.fill", productTypes: ["treatment"]),
                RoutineStep(order: 2, label: "Eye Care", icon: "eye.fill", productTypes: ["eye_cream", "eye_serum"]),
                RoutineStep(order: 3, label: "Moisturizer", icon: "humidity.fill", productTypes: ["moisturizer"])
            ]
        }
    }
}

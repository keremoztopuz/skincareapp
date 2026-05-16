//
//  SearchViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 2.05.2026.
//

import Foundation
import SwiftUI
internal import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    
    init() {
        Task {
            await fetchProducts()
        }
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @MainActor
    func fetchProducts() async {
        isLoading = true
        do {
            self.products = try await SupabaseService.shared.fetchProducts()
        } catch {
            print("Failed to fetch products for search: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

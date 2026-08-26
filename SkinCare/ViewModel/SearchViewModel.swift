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
    /// Set when the catalog fetch fails, so the tab can show a retry
    /// instead of a permanent, misleading "no products" state.
    @Published var loadFailed: Bool = false
    /// The message that matches the actual failure, not a blanket
    /// "check your connection".
    @Published var loadErrorMessage: String = AppStrings.internetConnectionRequired

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
                    || ($0.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    @MainActor
    func fetchProducts() async {
        isLoading = true
        loadFailed = false
        do {
            self.products = try await CatalogueService.shared.fetchProducts()
        } catch {
            self.products = []
            self.loadFailed = true
            self.loadErrorMessage = AppStrings.loadFailureMessage(for: error)
            AppLog.error("Catalog fetch failed", error)
        }
        isLoading = false
    }
}

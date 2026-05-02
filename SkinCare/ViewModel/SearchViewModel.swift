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
        fetchProducts()
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
    // dummy datas for now.
    func fetchProducts() {
        self.products = [
            Product(id: UUID(), name: "CeraVe Cleanser", category: "Face Cleanser", imageName: "product1"),
            Product(id: UUID(), name: "LaRoche-Posay SPF", category: "Sunscreen", imageName: "product2"),
            Product(id: UUID(), name: "The Ordinary Niacinamide", category: "Serum", imageName: "product3")
        ]
    }
}

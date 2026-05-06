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
    @Published var news: [News] = []
    @Published var products: [Product] = []
    
    init() {
        fetchNames()
        fetchArticles()
        fetchNews()
        fetchProducts()
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
    
    func fetchArticles() {
        self.articles = [
            Articles(id: UUID(), title: "How to Build a Skincare Routine", content: "A step-by-step guide...", category: "Skincare", imageName: "article1"),
            Articles(id: UUID(), title: "Understanding Your Skin Type", content: "Learn about different skintypes...", category: "Skincare", imageName: "article2"),
            Articles(id: UUID(), title: "Top 5 Ingredients for Acne", content: "Discover the bestingredients...", category: "Acne", imageName:"article3")
        ]
    }
    
    func fetchNews() {
        self.news = [
            News(id: UUID(), title: "New Skincare Product Launch", content: "Exciting news for skincare lovers...", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
            News(id: UUID(), title: "Health Benefits of Honey", content: "Discover the health benefits of honey...", createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
            News(id: UUID(), title: "Top 3 Travel Skincare Essentials", content: "Must-have items for your next trip...", createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
            News(id: UUID(), title: "How to Choose the Right Skincare Brand", content: "Tips for finding the perfect skincare brand...", createdAt: Calendar.current.date(byAdding: .day, value: -4, to: Date())!)
        ]
    }
    
    func fetchProducts() {
        self.products = [
                  Product(id: UUID(), name: "CeraVe Cleanser", category: "Face Cleanser", imageName: "product1"),
                  Product(id: UUID(), name: "La Roche-Posay SPF", category: "Sunscreen", imageName: "product2"),
                  Product(id: UUID(), name: "The Ordinary Niacinamide", category: "Serum", imageName:
          "product3"),
                  Product(id: UUID(), name: "Neutrogena Moisturizer", category: "Moisturizer", imageName:
          "product4"),
                  Product(id: UUID(), name: "Bioderma Micellar Water", category: "Cleanser", imageName: "product5")
        ]
    }
}

//
//  Product.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.04.2026.
//

import Foundation

struct Product: Identifiable, Codable {
    let id: UUID
    let name: String
    let brand: String?
    let description: String?
    let imageUrl: String?
    let productType: String?
    let activeIngredients: String?
    let usageTime: String?
    let frequency: String?
    let contraindications: String?
    let skinTypes: [String]?
    let isActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, brand, description
        case imageUrl = "image_url"
        case productType = "product_type"
        case activeIngredients = "active_ingredients"
        case usageTime = "usage_time"
        case frequency, contraindications
        case skinTypes = "skin_types"
        case isActive = "is_active"
    }
}

//
//  Product.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.04.2026.
//

import Foundation

struct Product: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let imageName: String
}

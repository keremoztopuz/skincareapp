//
//  News.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 29.04.2026.
//

import Foundation

struct News: Codable, Identifiable {
    let id: UUID 
    let title: String
    let content: String
    let createdAt: Date
}

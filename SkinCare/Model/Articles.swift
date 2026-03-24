//
//  Articles.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

// MARK: Article structure
import Foundation

struct Articles: Identifiable {
    let id : UUID
    let title : String
    let content : String
    let category : String
    let imageName : String
}

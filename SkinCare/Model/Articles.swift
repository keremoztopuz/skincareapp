//
//  Articles.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

// MARK: Article structure
import Foundation

struct Articles: Identifiable, Codable {
    let id : UUID
    let title : String
    let titleTr : String?
    let content : String?
    let contentTr : String?
    let imageUrl : String?
    let readTime : Int?
    let articleType : String?
    let isActive : Bool?
    let isFixed : Bool?
    let createdAt : Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content
        case titleTr = "title_tr"
        case contentTr = "content_tr"
        case imageUrl = "image_url"
        case readTime = "read_time"
        case articleType = "article_type"
        case isActive = "is_active"
        case isFixed = "is_fixed"
        case createdAt = "created_at"
    }

    /// Article copy lives in the database, so Localizable.strings cannot reach
    /// it. Follow the language the app is actually rendered in rather than the
    /// device locale, so the article matches the surrounding UI.
    private var prefersTurkish: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("tr") == true
    }

    var localizedTitle: String {
        guard prefersTurkish, let tr = titleTr, !tr.isEmpty else { return title }
        return tr
    }

    var localizedContent: String? {
        guard prefersTurkish, let tr = contentTr, !tr.isEmpty else { return content }
        return tr
    }
}

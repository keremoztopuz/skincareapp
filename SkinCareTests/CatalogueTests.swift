//
//  CatalogueTests.swift
//  SkinCareTests
//

import Testing
import Foundation
@testable import SkinCare

/// The wire contract between the proxy's catalogue endpoints and the structs
/// that decode them.
///
/// Both payloads below are verbatim responses from `/v1/catalogue/*`, not
/// hand-written approximations. The failure this guards against is a column
/// rename or a timestamp format change on the server producing an app that
/// builds, ships, and shows an empty catalogue.
struct CatalogueTests {

    private struct ProductList: Decodable { let products: [Product] }
    private struct ArticleList: Decodable { let articles: [Articles] }

    private let productPayload = """
    {"products": [{
      "id": "e60ebe90-6dd0-5a06-b68a-ad8561168944",
      "name": "Antirougeurs Rosamed SPF50+",
      "brand": "Avène",
      "description": "Sun protection for skin with persistent facial redness.",
      "description_tr": "Kalıcı yüz kızarıklığı olan ciltler için güneş koruması.",
      "image_url": null,
      "product_type": "sunscreen",
      "active_ingredients": "Thermal Spring Water, Ruscus Extract",
      "usage_time": "Morning",
      "frequency": "Daily",
      "contraindications": "Reapply every two hours in direct sun.",
      "skin_types": ["Sensitive", "Dry", "Normal"],
      "is_active": true
    }]}
    """.data(using: .utf8)!

    private let articlePayload = """
    {"articles": [{
      "id": "00abdb4a-4e39-50ff-8a59-5343206f71c2",
      "title": "Vitamin C And Why The Bottle Turns Orange",
      "title_tr": "C Vitamini ve Şişenin Neden Turuncuya Döndüğü",
      "content": "Vitamin C is an antioxidant.",
      "content_tr": "C vitamini bir antioksidan.",
      "image_url": "https://images.pexels.com/photos/7818182/pexels-photo-7818182.jpeg",
      "read_time": 1,
      "article_type": "Ingredient",
      "is_active": true,
      "is_fixed": false,
      "created_at": "2026-08-26T08:28:18.176+00:00"
    }]}
    """.data(using: .utf8)!

    @Test func productDecodesEveryColumnTheProxySends() throws {
        let decoded = try CatalogueService.payloadDecoder
            .decode(ProductList.self, from: productPayload)
        let product = try #require(decoded.products.first)

        #expect(product.id == UUID(uuidString: "e60ebe90-6dd0-5a06-b68a-ad8561168944"))
        #expect(product.brand == "Avène")
        #expect(product.productType == "sunscreen")
        #expect(product.activeIngredients == "Thermal Spring Water, Ruscus Extract")
        #expect(product.usageTime == "Morning")
        #expect(product.frequency == "Daily")
        #expect(product.contraindications != nil)
        #expect(product.skinTypes == ["Sensitive", "Dry", "Normal"])
        #expect(product.isActive == true)
        // A null column must decode as nil, not fail the whole list. 78 of
        // the 107 products currently have no photo.
        #expect(product.imageUrl == nil)
    }

    @Test func articleDecodesTheMillisecondTimestamp() throws {
        let decoded = try CatalogueService.payloadDecoder
            .decode(ArticleList.self, from: articlePayload)
        let article = try #require(decoded.articles.first)

        #expect(article.readTime == 1)
        #expect(article.isFixed == false)
        let created = try #require(article.createdAt)
        #expect(abs(created.timeIntervalSince1970 - 1787732898.176) < 0.001)
    }

    @Test func aTimestampWithoutFractionalSecondsStillDecodes() throws {
        let payload = String(data: articlePayload, encoding: .utf8)!
            .replacingOccurrences(of: "08:28:18.176+00:00", with: "08:28:18+00:00")
            .data(using: .utf8)!
        let decoded = try CatalogueService.payloadDecoder
            .decode(ArticleList.self, from: payload)
        #expect(decoded.articles.first?.createdAt != nil)
    }
}

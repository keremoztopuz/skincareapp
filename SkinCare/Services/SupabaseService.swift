import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
    
    private init() {}
    
    // MARK: - Fetch Products
    func fetchProducts() async throws -> [Product] {
        return try await client
            .from("products")
            .select("id, name, brand, image_url, is_active")
            .eq("is_active", value: true)
            .limit(20)
            .execute()
            .value
    }

    // MARK: - Fetch Recommended Products for a condition
    func fetchRecommendedProducts(for conditionKey: String) async throws -> [Product] {
        // Optimized: Fetching products directly through the join table in a single request
        struct ConditionWithProducts: Codable {
            let products: [Product]
        }

        let result: [ConditionWithProducts] = try await client
            .from("conditions")
            .select("products(id, name, brand, image_url, is_active)")
            .eq("key", value: conditionKey.lowercased())
            .eq("products.is_active", value: true)
            .execute()
            .value

        return result.first?.products ?? []
    }

    // MARK: - Fetch Articles
    func fetchArticles() async throws -> [Articles] {
        return try await client
            .from("articles")
            .select("id, title, image_url, is_active, created_at")
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .limit(10)
            .execute()
            .value
    }

    // MARK: - Fetch Single Product Detail
    func fetchProductDetail(id: UUID) async throws -> Product {
        return try await client
            .from("products")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch Single Article Detail
    func fetchArticleDetail(id: UUID) async throws -> Articles {
        return try await client
            .from("articles")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }
    }


// Helper structs for decoding relational joins
struct ConditionID: Codable {
    let id: UUID
}

struct ProductLink: Codable {
    let productId: UUID
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
    }
}

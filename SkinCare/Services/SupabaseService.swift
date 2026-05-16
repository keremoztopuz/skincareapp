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
            .select()
            .eq("is_active", value: true)
            .execute()
            .value
    }
    
    // MARK: - Fetch Recommended Products for a condition
    func fetchRecommendedProducts(for conditionKey: String) async throws -> [Product] {
        // 1. Get the condition ID first
        let condition: [ConditionID] = try await client
            .from("conditions")
            .select("id")
            .eq("key", value: conditionKey.lowercased())
            .execute()
            .value

        guard let conditionId = condition.first?.id else {
            return []
        }

        // 2. Get product IDs linked to this condition
        let links: [ProductLink] = try await client
            .from("product_conditions")
            .select("product_id")
            .eq("condition_id", value: conditionId)
            .execute()
            .value

        let productIds = links.map { $0.productId }
        guard !productIds.isEmpty else { return [] }

        // 3. Fetch the actual products
        return try await client
            .from("products")
            .select()
            .in("id", value: productIds)
            .eq("is_active", value: true)
            .execute()
            .value
    }
    
    // MARK: - Fetch Articles
    func fetchArticles() async throws -> [Articles] {
        return try await client
            .from("articles")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
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

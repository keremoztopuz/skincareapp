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
            .execute()
            .value
    }

    // MARK: - Fetch Recommended Products for a condition
    func fetchRecommendedProducts(for conditionKey: String) async throws -> [Product] {
        struct JoinRow: Codable {
            let products: Product
        }

        let result: [JoinRow] = try await client
            .from("product_conditions")
            // products must be !inner: filtering a non-inner embed nulls it
            // instead of dropping the row, and the non-optional JoinRow
            // decode would then fail on every inactive product.
            .select("products!inner(id, name, brand, image_url, is_active, product_type, skin_types, active_ingredients), conditions!inner(key)")
            .eq("conditions.key", value: conditionKey.lowercased())
            .eq("products.is_active", value: true)
            .execute()
            .value

        return result.map { $0.products }
    }

    // MARK: - Fetch Articles
    func fetchArticles() async throws -> [Articles] {
        return try await client
            .from("articles")
            .select("id, title, image_url, is_active, created_at")
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Fetch Products by Type
    func fetchProductsByType(_ productType: String) async throws -> [Product] {
        return try await client
            .from("products")
            .select("id, name, brand, image_url, is_active, product_type, skin_types")
            .eq("is_active", value: true)
            .eq("product_type", value: productType)
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

import Foundation

/// Products, articles and routine content, read through the analysis proxy.
///
/// The catalogue lives in Neon (PostgreSQL). The app does not hold a database
/// credential of any kind: it sends the same shared client token the analysis
/// endpoint already checks, and the role behind the proxy can only read the
/// four catalogue tables. That is the whole reason this type exists instead of
/// a database SDK — an embedded key in an IPA is a key anyone can extract.
///
/// Errors keep the distinction `AppStrings.loadFailureMessage(for:)` relies
/// on: a transport failure is rethrown as the original `URLError`, so the user
/// is told to check their connection, while anything the server said went
/// wrong surfaces as `CatalogueError` and never blames the network.
enum CatalogueError: Error {
    /// The proxy answered, but not with something usable.
    case server(code: String)
    /// The row is gone, or was never active.
    case notFound
    case badPayload
}

final class CatalogueService {
    static let shared = CatalogueService()
    private init() {}

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 60
        // The proxy sends Cache-Control on every catalogue response, so the
        // shared cache answers a second app open without a round trip.
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()

    /// Not private: the wire contract between the proxy and these structs is
    /// worth a test, and a test that builds its own decoder would pass while
    /// the app failed.
    static let payloadDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // The proxy pins created_at to milliseconds precisely so this
        // strategy works; Postgres microseconds would not decode.
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: text) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: text) else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Unrecognised timestamp"
                )
            }
            return date
        }
        return decoder
    }()

    private var decoder: JSONDecoder { Self.payloadDecoder }

    private struct ProductList: Decodable { let products: [Product] }
    private struct ArticleList: Decodable { let articles: [Articles] }
    private struct ErrorEnvelope: Decodable {
        struct Body: Decodable { let code: String }
        let error: Body
    }

    private func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(
            url: AnalysisConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        if !query.isEmpty { components.queryItems = query }

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(AnalysisConfig.sharedSecret)", forHTTPHeaderField: "Authorization")

        // No `catch` around this call: a URLError must reach the caller as
        // itself, because that is the only signal that says "connection", and
        // wrapping it would make every backend fault read as an offline phone.
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw CatalogueError.badPayload }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 404 { throw CatalogueError.notFound }
            let code = (try? decoder.decode(ErrorEnvelope.self, from: data))?.error.code
            throw CatalogueError.server(code: code ?? "http_\(http.statusCode)")
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            AppLog.error("Catalogue payload could not be decoded", error)
            throw CatalogueError.badPayload
        }
    }

    // MARK: - Products

    func fetchProducts() async throws -> [Product] {
        let list: ProductList = try await get("v1/catalogue/products")
        return list.products
    }

    func fetchProductsByType(_ productType: String) async throws -> [Product] {
        let list: ProductList = try await get(
            "v1/catalogue/products",
            query: [URLQueryItem(name: "type", value: productType)]
        )
        return list.products
    }

    func fetchProductDetail(id: UUID) async throws -> Product {
        try await get("v1/catalogue/products/\(id.uuidString)")
    }

    /// Products linked to one of the five condition keys.
    func fetchRecommendedProducts(for conditionKey: String) async throws -> [Product] {
        let list: ProductList = try await get(
            "v1/catalogue/recommendations",
            query: [URLQueryItem(name: "condition", value: conditionKey.lowercased())]
        )
        return list.products
    }

    // MARK: - Articles

    func fetchArticles() async throws -> [Articles] {
        let list: ArticleList = try await get("v1/catalogue/articles")
        return list.articles
    }

    func fetchArticleDetail(id: UUID) async throws -> Articles {
        try await get("v1/catalogue/articles/\(id.uuidString)")
    }
}

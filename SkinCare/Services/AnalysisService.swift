import UIKit

/// The six scores the analysis backend returns. All 0-100; higher is worse
/// for everything except `hydration`, where higher means better hydrated.
struct AnalysisScores: Decodable {
    let acne: Double
    let redness: Double
    let wrinkles: Double
    let eyebags: Double
    let pigmentation: Double
    let hydration: Double
}

enum AnalysisError: Error {
    case encodingFailed
    case network
    case server(code: String)
}

/// Calls the SkinCare analysis proxy, which fronts Gemini on Vertex AI.
///
/// The app never talks to Google directly: the proxy holds the cloud
/// credentials, strips EXIF from the photo, enforces the spend ceiling and
/// rate limits. The only secret this app carries is the shared client token
/// in `AnalysisConfig`, which merely tells the proxy "this request came from
/// something holding the app's token".
final class AnalysisService {
    static let shared = AnalysisService()
    private init() {}

    /// Above these percentages a condition is named in `detectedCondition`.
    /// Carried over from the retired on-device model's calibrated cut-offs.
    static let acneThreshold = 66.0
    static let rednessThreshold = 62.0

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }()

    private struct Envelope: Decodable {
        let scores: AnalysisScores
    }

    private struct ErrorEnvelope: Decodable {
        struct Body: Decodable { let code: String }
        let error: Body
    }

    /// One shot, no client-side retry: the proxy already retries transient
    /// upstream failures internally, and retrying here would double-spend
    /// the daily budget on every flake.
    func analyze(image: UIImage, skinType: String?, age: Int?) async throws -> AnalysisScores {
        guard let jpeg = image.jpegData(compressionQuality: 0.82) else {
            throw AnalysisError.encodingFailed
        }

        let boundary = "skincare-\(UUID().uuidString)"
        var request = URLRequest(url: AnalysisConfig.baseURL.appendingPathComponent("v1/analyze"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(AnalysisConfig.sharedSecret)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"image\"; filename=\"face.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(jpeg)
        body.append("\r\n".data(using: .utf8)!)
        if let skinType { field("skin_type", skinType) }
        if let age { field("age", String(age)) }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AnalysisError.network
        }

        guard let http = response as? HTTPURLResponse else { throw AnalysisError.network }
        guard (200..<300).contains(http.statusCode) else {
            let code = (try? JSONDecoder().decode(ErrorEnvelope.self, from: data))?.error.code
            throw AnalysisError.server(code: code ?? "http_\(http.statusCode)")
        }
        do {
            return try JSONDecoder().decode(Envelope.self, from: data).scores
        } catch {
            throw AnalysisError.server(code: "bad_payload")
        }
    }
}

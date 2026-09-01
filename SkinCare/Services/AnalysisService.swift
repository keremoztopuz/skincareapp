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
        // The request timeout resets on every byte of progress, so a
        // trickling upload never trips it; without a resource ceiling the
        // system default is seven days of "Analyzing".
        configuration.timeoutIntervalForResource = 120
        return URLSession(configuration: configuration)
    }()

    /// The proxy rejects bodies over 4 MiB and downscales to 768px anyway,
    /// so anything beyond this edge length is wasted upload on cellular.
    private static let maxUploadEdge: CGFloat = 1024

    private func uploadJPEG(from image: UIImage) -> Data? {
        let scaled: UIImage
        let longestEdge = max(image.size.width, image.size.height)
        if longestEdge > Self.maxUploadEdge {
            let ratio = Self.maxUploadEdge / longestEdge
            let targetSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            scaled = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        } else {
            scaled = image
        }
        return scaled.jpegData(compressionQuality: 0.82)
    }

    private struct Envelope: Decodable {
        let scores: AnalysisScores
        // Optional on purpose: a proxy that predates regions simply omits
        // the field, and this client keeps working against it.
        let regions: [String: [StoredZones.Rect]]?
    }

    private struct ErrorEnvelope: Decodable {
        struct Body: Decodable { let code: String }
        let error: Body
    }

    /// One shot, no client-side retry: the proxy already retries transient
    /// upstream failures internally, and retrying here would double-spend
    /// the daily budget on every flake.
    /// The regions dictionary is keyed by the five visible condition names
    /// and is empty against a proxy that does not return regions yet.
    func analyze(
        image: UIImage, skinType: String?, age: Int?
    ) async throws -> (scores: AnalysisScores, regions: [String: [StoredZones.Rect]]) {
        guard let jpeg = uploadJPEG(from: image), jpeg.count < 4 * 1024 * 1024 else {
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
            let envelope = try JSONDecoder().decode(Envelope.self, from: data)
            return (envelope.scores, envelope.regions ?? [:])
        } catch {
            throw AnalysisError.server(code: "bad_payload")
        }
    }
}

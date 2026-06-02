import Foundation
import UIKit

struct GeminiSkinAnalysisResult: Codable {
    struct Dimension: Codable {
        let score: Double
        let confidence: Double
        let reason: String

        func clamped() -> Dimension {
            Dimension(
                score: min(max(score, 0), 100),
                confidence: min(max(confidence, 0), 1),
                reason: reason
            )
        }
    }

    let wrinkles: Dimension
    let eyebags: Dimension
    let pigmentation: Dimension
    let hydration: Dimension

    func clamped() -> GeminiSkinAnalysisResult {
        GeminiSkinAnalysisResult(
            wrinkles: wrinkles.clamped(),
            eyebags: eyebags.clamped(),
            pigmentation: pigmentation.clamped(),
            hydration: hydration.clamped()
        )
    }
}

enum GeminiVLMError: Error {
    case missingAPIKey
    case invalidResponse
    case invalidResponseText
}

final class GeminiVLMService {
    static let shared = GeminiVLMService()

    private let session: URLSession
    private let modelName = "gemini-2.5-flash"

    private init() {
        self.session = URLSession(configuration: .default)
    }

    func analyzeFace(_ image: UIImage) async throws -> GeminiSkinAnalysisResult {
        let apiKey = GeminiConfig.apiKey

        guard let imageData = image.jpegData(compressionQuality: 0.82) else {
            throw GeminiVLMError.invalidResponse
        }

        let requestBody = GeminiRequest.make(imageBase64: imageData.base64EncodedString())
        let requestData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        var request = URLRequest(
            url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent")!
        )
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw GeminiVLMError.invalidResponse
        }

        let apiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let responseText = apiResponse.responseText else {
            throw GeminiVLMError.invalidResponseText
        }

        let jsonText = GeminiVLMService.stripCodeFences(responseText)
        guard let jsonData = jsonText.data(using: .utf8) else {
            throw GeminiVLMError.invalidResponseText
        }

        return try JSONDecoder().decode(GeminiSkinAnalysisResult.self, from: jsonData).clamped()
    }
}

private enum GeminiRequest {
    static func make(imageBase64: String) -> [String: Any] {
        [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        [
                            "text": """
                            Analyze this face crop for cosmetic skin assessment.
                            Return only JSON.
                            Assess wrinkles, eyebags, pigmentation, and hydration.
                            Acne and redness are handled separately and must not be included.
                            Use scores from 0 to 100, where higher means the issue is more visible or severe.
                            If a signal is weak or unclear, keep the score low and confidence low.
                            """
                        ],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageBase64
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "responseMimeType": "application/json",
                "responseSchema": GeminiRequest.responseSchema
            ]
        ]
    }

    private static let responseSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "wrinkles": GeminiRequest.dimensionSchema,
            "eyebags": GeminiRequest.dimensionSchema,
            "pigmentation": GeminiRequest.dimensionSchema,
            "hydration": GeminiRequest.dimensionSchema
        ],
        "required": ["wrinkles", "eyebags", "pigmentation", "hydration"]
    ]

    private static let dimensionSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "score": [
                "type": "number",
                "description": "Severity score from 0 to 100."
            ],
            "confidence": [
                "type": "number",
                "description": "Confidence from 0 to 1."
            ],
            "reason": [
                "type": "string",
                "description": "Short explanation."
            ]
        ],
        "required": ["score", "confidence", "reason"]
    ]
}

private struct GeminiResponse: Decodable {
    let candidates: [Candidate]?

    var responseText: String? {
        candidates?
            .compactMap { $0.content?.parts?.compactMap(\.text).joined() }
            .first(where: { !$0.isEmpty })
    }

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }
}

private extension GeminiVLMService {
    static func stripCodeFences(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("```") {
            let lines = trimmed.split(separator: "\n", omittingEmptySubsequences: false)
            if lines.count >= 3 {
                return lines.dropFirst().dropLast().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return trimmed
    }
}

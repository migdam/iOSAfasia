//
//  TranslationService.swift
//  AphasiaTherapy
//
//  AI-powered translation service supporting multiple languages
//

import Foundation

class TranslationService {
    static let shared = TranslationService()

    private let apiBaseURL: String
    private let apiKey: String
    let cacheManager = TranslationCacheManager()

    init(apiBaseURL: String = "https://api.openai.com/v1", apiKey: String = "") {
        self.apiBaseURL = apiBaseURL
        // In production, load from secure storage or environment
        self.apiKey = apiKey.isEmpty ? UserDefaults.standard.string(forKey: "translation_api_key") ?? "" : apiKey
    }

    // MARK: - Translation Methods

    /// Translate a single text string to target language
    func translate(
        text: String,
        to targetLanguage: Language,
        from sourceLanguage: Language = .english
    ) async throws -> String {
        // Check cache first
        if let cached = cacheManager.getCachedTranslation(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        ) {
            return cached
        }

        // If same language, return original
        if sourceLanguage == targetLanguage {
            return text
        }

        // Perform AI translation
        let translation = try await performAITranslation(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )

        // Cache the result
        cacheManager.cacheTranslation(
            text: text,
            translation: translation,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )

        return translation
    }

    /// Translate multiple texts in batch (more efficient)
    func translateBatch(
        texts: [String],
        to targetLanguage: Language,
        from sourceLanguage: Language = .english
    ) async throws -> [String: String] {
        var results: [String: String] = [:]
        var textsToTranslate: [String] = []

        // Check cache for each text
        for text in texts {
            if let cached = cacheManager.getCachedTranslation(
                text: text,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            ) {
                results[text] = cached
            } else {
                textsToTranslate.append(text)
            }
        }

        // If all cached, return immediately
        if textsToTranslate.isEmpty {
            return results
        }

        // Translate remaining texts
        let translations = try await performBatchAITranslation(
            texts: textsToTranslate,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )

        // Cache and add to results
        for (text, translation) in translations {
            cacheManager.cacheTranslation(
                text: text,
                translation: translation,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            results[text] = translation
        }

        return results
    }

    // MARK: - AI Translation Implementation

    private func performAITranslation(
        text: String,
        sourceLanguage: Language,
        targetLanguage: Language
    ) async throws -> String {
        // Use OpenAI API or similar for translation
        let prompt = """
        Translate the following text from \(sourceLanguage.displayName) to \(targetLanguage.displayName).
        Only provide the translation, no explanations.
        Keep the same tone and formality level.
        For medical/therapy terms, use professional terminology.

        Text to translate:
        \(text)

        Translation:
        """

        let translation = try await callLLMAPI(prompt: prompt)
        return translation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func performBatchAITranslation(
        texts: [String],
        sourceLanguage: Language,
        targetLanguage: Language
    ) async throws -> [String: String] {
        let numberedTexts = texts.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")

        let prompt = """
        Translate the following texts from \(sourceLanguage.displayName) to \(targetLanguage.displayName).
        Return each translation on a new line, prefixed with the same number.
        Keep the same tone and formality level.
        For medical/therapy terms, use professional terminology.

        Texts to translate:
        \(numberedTexts)

        Translations:
        """

        let response = try await callLLMAPI(prompt: prompt)

        // Parse response
        var results: [String: String] = [:]
        let lines = response.components(separatedBy: .newlines)

        for (index, text) in texts.enumerated() {
            // Find line starting with number
            if let line = lines.first(where: { $0.hasPrefix("\(index + 1).") }) {
                let translation = line.replacingOccurrences(of: "^\(index + 1)\\. ", with: "", options: .regularExpression)
                results[text] = translation.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return results
    }

    private func callLLMAPI(prompt: String) async throws -> String {
        // If no API key, throw error
        guard !apiKey.isEmpty else {
            throw TranslationError.noAPIKey
        }

        // Prepare request for OpenAI API
        guard let url = URL(string: "\(apiBaseURL)/chat/completions") else {
            throw TranslationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a professional translator specializing in medical and therapy terminology."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TranslationError.apiError
        }

        // Parse response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }

        throw TranslationError.parsingError
    }
}

// MARK: - Translation Cache Manager

class TranslationCacheManager {
    private let cacheKey = "translation_cache"
    private var cache: [String: String] = [:]

    init() {
        loadCache()
    }

    func getCachedTranslation(text: String, sourceLanguage: Language, targetLanguage: Language) -> String? {
        let key = cacheKey(text: text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        return cache[key]
    }

    func cacheTranslation(text: String, translation: String, sourceLanguage: Language, targetLanguage: Language) {
        let key = cacheKey(text: text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        cache[key] = translation
        saveCache()
    }

    private func cacheKey(text: String, sourceLanguage: Language, targetLanguage: Language) -> String {
        // Use the source text directly so cache keys stay stable across launches.
        // String.hashValue is seeded per process, which previously made persisted
        // translations un-retrievable after the app restarted.
        return "\(sourceLanguage.rawValue)_\(targetLanguage.rawValue)_\(text)"
    }

    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            cache = decoded
        }
    }

    private func saveCache() {
        if let encoded = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    func clearCache() {
        cache.removeAll()
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
}

// MARK: - Translation Errors

enum TranslationError: LocalizedError {
    case noAPIKey
    case invalidURL
    case apiError
    case parsingError
    case networkError

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Translation API key not configured"
        case .invalidURL:
            return "Invalid API URL"
        case .apiError:
            return "Translation API error"
        case .parsingError:
            return "Failed to parse translation response"
        case .networkError:
            return "Network error during translation"
        }
    }
}

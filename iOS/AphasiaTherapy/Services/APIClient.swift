//
//  APIClient.swift
//  AphasiaTherapy
//
//  API client for communicating with the FastAPI backend
//

import Foundation
import Combine

class APIClient: ObservableObject {
    @Published var isLoading = false
    @Published var error: APIError?

    private let baseURL: String
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()

    init(baseURL: String = "http://localhost:8000") {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Health Check

    func healthCheck() async throws -> HealthResponse {
        try await request(endpoint: "/health", method: "GET")
    }

    func detailedHealthCheck() async throws -> DetailedHealthResponse {
        try await request(endpoint: "/health/detailed", method: "GET")
    }

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        return try await request(
            endpoint: "/auth/login",
            method: "POST",
            body: loginRequest
        )
    }

    func register(email: String, password: String, name: String, language: String) async throws -> AuthResponse {
        let registerRequest = RegisterRequest(
            email: email,
            password: password,
            name: name,
            preferredLanguage: language
        )
        return try await request(
            endpoint: "/auth/register",
            method: "POST",
            body: registerRequest
        )
    }

    // MARK: - User Profile

    func getUserProfile(token: String) async throws -> UserProfile {
        try await authenticatedRequest(
            endpoint: "/users/profile",
            method: "GET",
            token: token
        )
    }

    func updateUserProfile(token: String, profile: UserProfile) async throws -> UserProfile {
        try await authenticatedRequest(
            endpoint: "/users/profile",
            method: "PUT",
            token: token,
            body: profile
        )
    }

    // MARK: - Therapy Sessions

    func getTherapySessions(token: String, language: String? = nil) async throws -> [TherapySession] {
        var endpoint = "/therapy/sessions"
        if let lang = language {
            endpoint += "?language=\(lang)"
        }
        return try await authenticatedRequest(
            endpoint: endpoint,
            method: "GET",
            token: token
        )
    }

    func getSessionExercises(token: String, sessionId: String) async throws -> [Exercise] {
        try await authenticatedRequest(
            endpoint: "/therapy/exercises/\(sessionId)",
            method: "GET",
            token: token
        )
    }

    func submitSessionProgress(token: String, sessionId: String, progress: ProgressSubmission) async throws -> SessionProgress {
        try await authenticatedRequest(
            endpoint: "/therapy/sessions/\(sessionId)/progress",
            method: "POST",
            token: token,
            body: progress
        )
    }

    // MARK: - Progress

    func getUserProgress(token: String) async throws -> UserProgress {
        try await authenticatedRequest(
            endpoint: "/users/progress",
            method: "GET",
            token: token
        )
    }

    // MARK: - Generic Request Methods

    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    private func authenticatedRequest<T: Decodable>(
        endpoint: String,
        method: String,
        token: String,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case unauthorized
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Health Response Models

struct HealthResponse: Codable {
    let status: String
    let timestamp: String
}

struct DetailedHealthResponse: Codable {
    let status: String
    let timestamp: String
    let version: String
    let database: String
    let uptime: Int
}

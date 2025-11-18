//
//  AuthenticationManager.swift
//  AphasiaTherapy
//
//  Manages user authentication and session state
//

import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private let keychainService = KeychainService()

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Authentication Status

    func checkAuthenticationStatus() {
        if let token = keychainService.getToken(),
           let userData = keychainService.getUserData() {
            self.authToken = token
            self.currentUser = userData
            self.isAuthenticated = true
        }
    }

    // MARK: - Login

    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.login(email: email, password: password)

            // Save to keychain
            keychainService.saveToken(response.accessToken)
            keychainService.saveUserData(response.user)

            // Update state
            self.authToken = response.accessToken
            self.currentUser = response.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Register

    @MainActor
    func register(email: String, password: String, name: String, language: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.register(
                email: email,
                password: password,
                name: name,
                language: language
            )

            // Save to keychain
            keychainService.saveToken(response.accessToken)
            keychainService.saveUserData(response.user)

            // Update state
            self.authToken = response.accessToken
            self.currentUser = response.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Logout

    @MainActor
    func logout() {
        keychainService.clearAll()
        authToken = nil
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Update Profile

    @MainActor
    func updateProfile(_ profile: UserProfile) async {
        guard let token = authToken else { return }

        isLoading = true
        errorMessage = nil

        do {
            let updatedProfile = try await apiClient.updateUserProfile(token: token, profile: profile)

            // Update current user with new data
            if var user = currentUser {
                user.name = updatedProfile.name
                user.email = updatedProfile.email
                user.preferredLanguage = updatedProfile.preferredLanguage
                user.updatedAt = Date()

                keychainService.saveUserData(user)
                self.currentUser = user
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Keychain Service

class KeychainService {
    private let service = "com.aphasiatherapy.app"
    private let tokenKey = "authToken"
    private let userDataKey = "userData"

    func saveToken(_ token: String) {
        save(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return get(forKey: tokenKey)
    }

    func saveUserData(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            save(String(data: encoded, encoding: .utf8) ?? "", forKey: userDataKey)
        }
    }

    func getUserData() -> User? {
        guard let jsonString = get(forKey: userDataKey),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clearAll() {
        delete(forKey: tokenKey)
        delete(forKey: userDataKey)
    }

    // MARK: - Private Methods

    private func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

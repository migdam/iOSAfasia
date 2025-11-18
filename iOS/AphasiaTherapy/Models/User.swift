//
//  User.swift
//  AphasiaTherapy
//
//  User data model
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var name: String
    var preferredLanguage: String
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case preferredLanguage = "preferred_language"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var preferredLanguage: String
    var settings: UserSettings

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case preferredLanguage = "preferred_language"
        case settings
    }
}

struct UserSettings: Codable {
    var notifications: Bool
    var soundEffects: Bool
    var hapticFeedback: Bool
    var autoSave: Bool

    static let `default` = UserSettings(
        notifications: true,
        soundEffects: true,
        hapticFeedback: true,
        autoSave: true
    )
}

struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let preferredLanguage: String

    enum CodingKeys: String, CodingKey {
        case email
        case password
        case name
        case preferredLanguage = "preferred_language"
    }
}

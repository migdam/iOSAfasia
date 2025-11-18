//
//  AphasiaTherapyApp.swift
//  AphasiaTherapy
//
//  Aphasia Speech Therapy App for iOS
//  Supports iPhone and iPad
//

import SwiftUI

@main
struct AphasiaTherapyApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var apiClient = APIClient()
    @StateObject private var localizationManager = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(apiClient)
                .environmentObject(localizationManager)
                .preferredColorScheme(.light)
        }
    }
}

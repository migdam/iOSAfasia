//
//  ContentView.swift
//  AphasiaTherapy
//
//  Main content view that handles navigation based on authentication state
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        Group {
            if authManager.isAuthenticated || authManager.isGuest {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            // Check for stored authentication token
            authManager.checkAuthenticationStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

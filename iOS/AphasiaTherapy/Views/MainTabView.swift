//
//  MainTabView.swift
//  AphasiaTherapy
//
//  Main tab navigation for the app
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(localizationManager.localize("home"), systemImage: "house.fill")
                }
                .tag(0)

            SessionsView()
                .tabItem {
                    Label(localizationManager.localize("sessions"), systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            ProgressDashboardView()
                .tabItem {
                    Label(localizationManager.localize("progress"), systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(localizationManager.localize("profile"), systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

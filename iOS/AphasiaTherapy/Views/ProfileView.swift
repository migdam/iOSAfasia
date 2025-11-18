//
//  ProfileView.swift
//  AphasiaTherapy
//
//  User profile and settings view
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedLanguage: Language = .english
    @State private var notificationsEnabled = true
    @State private var soundEffectsEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var autoSaveEnabled = true
    @State private var showingLogoutAlert = false
    @State private var showingSaveAlert = false
    @State private var isEditingProfile = false

    var body: some View {
        NavigationView {
            List {
                // Profile section
                Section {
                    HStack(spacing: 15) {
                        // Avatar
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text(authManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 5) {
                            Text(authManager.currentUser?.name ?? "")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: { isEditingProfile.toggle() }) {
                            Text(localizationManager.localize("edit"))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                }

                // Account settings
                Section(header: Text(localizationManager.localize("account_settings"))) {
                    if isEditingProfile {
                        TextField(localizationManager.localize("name"), text: $name)

                        TextField(localizationManager.localize("email"), text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        Button(localizationManager.localize("save")) {
                            saveProfile()
                        }
                        .foregroundColor(.blue)
                    }

                    // Language selector
                    HStack {
                        Text(localizationManager.localize("language_preference"))
                        Spacer()
                        Picker("", selection: $selectedLanguage) {
                            ForEach(Language.allCases) { language in
                                HStack {
                                    Text(language.flag)
                                    Text(language.displayName)
                                }.tag(language)
                            }
                        }
                        .onChange(of: selectedLanguage) { newValue in
                            localizationManager.setLanguage(newValue)
                        }
                    }
                }

                // App settings
                Section(header: Text("App Settings")) {
                    Toggle(localizationManager.localize("notifications"), isOn: $notificationsEnabled)
                    Toggle(localizationManager.localize("sound_effects"), isOn: $soundEffectsEnabled)
                    Toggle(localizationManager.localize("haptic_feedback"), isOn: $hapticFeedbackEnabled)
                    Toggle(localizationManager.localize("auto_save"), isOn: $autoSaveEnabled)
                }

                // About section
                Section(header: Text(localizationManager.localize("about"))) {
                    HStack {
                        Text(localizationManager.localize("version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }

                    NavigationLink(destination: AboutView()) {
                        Text(localizationManager.localize("about"))
                    }

                    NavigationLink(destination: SupportView()) {
                        Text(localizationManager.localize("support"))
                    }
                }

                // Logout section
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Spacer()
                            Text(localizationManager.localize("logout"))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(localizationManager.localize("profile"))
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        authManager.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Profile Updated", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                loadUserData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func loadUserData() {
        if let user = authManager.currentUser {
            name = user.name
            email = user.email
            if let language = Language(rawValue: user.preferredLanguage) {
                selectedLanguage = language
            }
        }
    }

    private func saveProfile() {
        let profile = UserProfile(
            name: name,
            email: email,
            preferredLanguage: selectedLanguage.rawValue,
            settings: UserSettings(
                notifications: notificationsEnabled,
                soundEffects: soundEffectsEnabled,
                hapticFeedback: hapticFeedbackEnabled,
                autoSave: autoSaveEnabled
            )
        )

        Task {
            await authManager.updateProfile(profile)
            await MainActor.run {
                isEditingProfile = false
                showingSaveAlert = true
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)

                Text(localizationManager.localize("app_name"))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)

                Divider()

                Text("About")
                    .font(.headline)
                    .padding(.top)

                Text("Aphasia Speech Therapy is a comprehensive application designed to help individuals with aphasia improve their communication skills through interactive exercises and therapy sessions.")
                    .font(.body)

                Text("Features")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "checkmark.circle", text: "Interactive therapy sessions")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Progress tracking")
                    FeatureRow(icon: "globe", text: "Multi-language support")
                    FeatureRow(icon: "iphone", text: "Works on iPhone and iPad")
                }

                Divider()

                Text("© 2024 Aphasia Therapy. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Support View

struct SupportView: View {
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        List {
            Section(header: Text("Contact")) {
                HStack {
                    Image(systemName: "envelope")
                    Text("support@aphasiatherapy.com")
                        .font(.subheadline)
                }

                HStack {
                    Image(systemName: "globe")
                    Link("Visit our website", destination: URL(string: "https://aphasiatherapy.com")!)
                        .font(.subheadline)
                }
            }

            Section(header: Text("Help Topics")) {
                NavigationLink(destination: Text("Getting Started Guide")) {
                    Text("Getting Started")
                }
                NavigationLink(destination: Text("How to use exercises")) {
                    Text("Using Exercises")
                }
                NavigationLink(destination: Text("Understanding your progress")) {
                    Text("Progress Tracking")
                }
                NavigationLink(destination: Text("FAQ")) {
                    Text("Frequently Asked Questions")
                }
            }

            Section(header: Text("Feedback")) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "star")
                        Text("Rate this app")
                    }
                }

                Button(action: {}) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble")
                        Text("Report an issue")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(localizationManager.localize("support"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationManager())
            .environmentObject(LocalizationManager())
    }
}

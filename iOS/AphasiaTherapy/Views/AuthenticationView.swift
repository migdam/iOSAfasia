//
//  AuthenticationView.swift
//  AphasiaTherapy
//
//  Authentication screen with login and registration
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and title
                        VStack(spacing: 15) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 80))
                                .foregroundColor(.white)

                            Text(localizationManager.localize("app_name"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)

                        // Form card
                        VStack(spacing: 20) {
                            // Mode selector
                            Picker("", selection: $isLoginMode) {
                                Text(localizationManager.localize("login")).tag(true)
                                Text(localizationManager.localize("register")).tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 10)

                            // Name field (registration only)
                            if !isLoginMode {
                                TextField(localizationManager.localize("name"), text: $name)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                            }

                            // Email field
                            TextField(localizationManager.localize("email"), text: $email)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)

                            // Password field
                            SecureField(localizationManager.localize("password"), text: $password)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(isLoginMode ? .password : .newPassword)

                            // Confirm password (registration only)
                            if !isLoginMode {
                                SecureField(localizationManager.localize("confirm_password"), text: $confirmPassword)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .textContentType(.newPassword)

                                // Language selector (registration only)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localizationManager.localize("language_preference"))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Picker("", selection: $localizationManager.currentLanguage) {
                                        ForEach(Language.allCases) { language in
                                            HStack {
                                                Text(language.flag)
                                                Text(language.displayName)
                                            }.tag(language)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }

                            // Error message
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            // Submit button
                            Button(action: handleSubmit) {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isLoginMode ? localizationManager.localize("login") : localizationManager.localize("create_account"))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(authManager.isLoading || !isFormValid)

                            // Forgot password link (login only)
                            if isLoginMode {
                                Button(localizationManager.localize("forgot_password")) {
                                    // Handle forgot password
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }

    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty &&
                   password == confirmPassword && password.count >= 6
        }
    }

    private func handleSubmit() {
        Task {
            if isLoginMode {
                await authManager.login(email: email, password: password)
            } else {
                await authManager.register(
                    email: email,
                    password: password,
                    name: name,
                    language: localizationManager.currentLanguage.rawValue
                )
            }
        }
    }
}

// MARK: - Custom TextField Style

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationManager())
            .environmentObject(LocalizationManager())
    }
}

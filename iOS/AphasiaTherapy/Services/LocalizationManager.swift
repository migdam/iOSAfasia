//
//  LocalizationManager.swift
//  AphasiaTherapy
//
//  Manages internationalization and localization
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .english {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }

    private var translations: [Language: [String: String]] = [:]

    init() {
        loadTranslations()

        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }

    func localize(_ key: String) -> String {
        translations[currentLanguage]?[key] ?? key
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
    }

    private func loadTranslations() {
        // English translations
        translations[.english] = [
            // Common
            "app_name": "Aphasia Therapy",
            "continue": "Continue",
            "cancel": "Cancel",
            "save": "Save",
            "delete": "Delete",
            "edit": "Edit",
            "done": "Done",
            "next": "Next",
            "previous": "Previous",
            "submit": "Submit",
            "close": "Close",

            // Authentication
            "login": "Log In",
            "register": "Register",
            "logout": "Log Out",
            "email": "Email",
            "password": "Password",
            "name": "Name",
            "confirm_password": "Confirm Password",
            "forgot_password": "Forgot Password?",
            "no_account": "Don't have an account?",
            "have_account": "Already have an account?",
            "create_account": "Create Account",

            // Main Tabs
            "home": "Home",
            "sessions": "Sessions",
            "progress": "Progress",
            "profile": "Profile",

            // Home
            "welcome": "Welcome",
            "daily_goal": "Daily Goal",
            "continue_session": "Continue Session",
            "start_new": "Start New Session",
            "recent_sessions": "Recent Sessions",

            // Sessions
            "all_sessions": "All Sessions",
            "filter_by_type": "Filter by Type",
            "filter_by_difficulty": "Filter by Difficulty",
            "difficulty_beginner": "Beginner",
            "difficulty_intermediate": "Intermediate",
            "difficulty_advanced": "Advanced",
            "estimated_time": "Estimated Time",
            "minutes": "minutes",
            "exercises": "Exercises",

            // Exercise Types
            "word_naming": "Word Naming",
            "sentence_completion": "Sentence Completion",
            "comprehension": "Comprehension",
            "repetition": "Repetition",
            "reading": "Reading",
            "writing": "Writing",

            // Progress
            "your_progress": "Your Progress",
            "total_sessions": "Total Sessions",
            "completed_sessions": "Completed Sessions",
            "average_score": "Average Score",
            "time_spent": "Time Spent",
            "current_streak": "Current Streak",
            "days": "days",
            "performance_chart": "Performance Chart",
            "session_history": "Session History",

            // Profile
            "account_settings": "Account Settings",
            "language_preference": "Language Preference",
            "notifications": "Notifications",
            "sound_effects": "Sound Effects",
            "haptic_feedback": "Haptic Feedback",
            "auto_save": "Auto Save",
            "about": "About",
            "version": "Version",
            "support": "Support",

            // Exercise Session
            "exercise_progress": "Exercise Progress",
            "question": "Question",
            "your_answer": "Your Answer",
            "check_answer": "Check Answer",
            "correct": "Correct!",
            "incorrect": "Incorrect",
            "hint": "Hint",
            "skip": "Skip",
            "finish_session": "Finish Session",

            // Results
            "session_complete": "Session Complete!",
            "your_score": "Your Score",
            "time_taken": "Time Taken",
            "correct_answers": "Correct Answers",
            "view_details": "View Details",
            "try_again": "Try Again",
            "back_to_home": "Back to Home",

            // Errors
            "error": "Error",
            "error_loading": "Error loading data",
            "error_network": "Network error. Please check your connection.",
            "error_auth": "Authentication error. Please log in again.",
            "try_again": "Try Again",
        ]

        // Polish translations
        translations[.polish] = [
            // Common
            "app_name": "Terapia Afazji",
            "continue": "Kontynuuj",
            "cancel": "Anuluj",
            "save": "Zapisz",
            "delete": "Usuń",
            "edit": "Edytuj",
            "done": "Gotowe",
            "next": "Następny",
            "previous": "Poprzedni",
            "submit": "Wyślij",
            "close": "Zamknij",

            // Authentication
            "login": "Zaloguj się",
            "register": "Zarejestruj",
            "logout": "Wyloguj",
            "email": "Email",
            "password": "Hasło",
            "name": "Imię",
            "confirm_password": "Potwierdź hasło",
            "forgot_password": "Zapomniałeś hasła?",
            "no_account": "Nie masz konta?",
            "have_account": "Masz już konto?",
            "create_account": "Utwórz konto",

            // Main Tabs
            "home": "Start",
            "sessions": "Sesje",
            "progress": "Postępy",
            "profile": "Profil",

            // Home
            "welcome": "Witaj",
            "daily_goal": "Dzienny cel",
            "continue_session": "Kontynuuj sesję",
            "start_new": "Rozpocznij nową sesję",
            "recent_sessions": "Ostatnie sesje",

            // Sessions
            "all_sessions": "Wszystkie sesje",
            "filter_by_type": "Filtruj według typu",
            "filter_by_difficulty": "Filtruj według trudności",
            "difficulty_beginner": "Początkujący",
            "difficulty_intermediate": "Średniozaawansowany",
            "difficulty_advanced": "Zaawansowany",
            "estimated_time": "Szacowany czas",
            "minutes": "minut",
            "exercises": "Ćwiczenia",

            // Exercise Types
            "word_naming": "Nazywanie słów",
            "sentence_completion": "Uzupełnianie zdań",
            "comprehension": "Rozumienie",
            "repetition": "Powtarzanie",
            "reading": "Czytanie",
            "writing": "Pisanie",

            // Progress
            "your_progress": "Twoje postępy",
            "total_sessions": "Wszystkie sesje",
            "completed_sessions": "Ukończone sesje",
            "average_score": "Średni wynik",
            "time_spent": "Spędzony czas",
            "current_streak": "Obecna seria",
            "days": "dni",
            "performance_chart": "Wykres wyników",
            "session_history": "Historia sesji",

            // Profile
            "account_settings": "Ustawienia konta",
            "language_preference": "Preferowany język",
            "notifications": "Powiadomienia",
            "sound_effects": "Efekty dźwiękowe",
            "haptic_feedback": "Wibracje",
            "auto_save": "Automatyczny zapis",
            "about": "O aplikacji",
            "version": "Wersja",
            "support": "Wsparcie",

            // Exercise Session
            "exercise_progress": "Postęp ćwiczeń",
            "question": "Pytanie",
            "your_answer": "Twoja odpowiedź",
            "check_answer": "Sprawdź odpowiedź",
            "correct": "Poprawnie!",
            "incorrect": "Niepoprawnie",
            "hint": "Podpowiedź",
            "skip": "Pomiń",
            "finish_session": "Zakończ sesję",

            // Results
            "session_complete": "Sesja ukończona!",
            "your_score": "Twój wynik",
            "time_taken": "Zużyty czas",
            "correct_answers": "Poprawne odpowiedzi",
            "view_details": "Zobacz szczegóły",
            "try_again": "Spróbuj ponownie",
            "back_to_home": "Powrót do strony głównej",

            // Errors
            "error": "Błąd",
            "error_loading": "Błąd wczytywania danych",
            "error_network": "Błąd sieci. Sprawdź połączenie.",
            "error_auth": "Błąd uwierzytelniania. Zaloguj się ponownie.",
            "try_again": "Spróbuj ponownie",
        ]
    }
}

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case polish = "pl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .polish: return "Polski"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .polish: return "🇵🇱"
        }
    }
}

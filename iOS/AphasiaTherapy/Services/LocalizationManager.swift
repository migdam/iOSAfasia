//
//  LocalizationManager.swift
//  AphasiaTherapy
//
//  Manages internationalization and localization with AI-powered translation
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .english {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            // Pre-load translations for the new language
            Task {
                await loadAITranslations()
            }
        }
    }

    @Published var isLoadingTranslations = false
    @Published var useAITranslation = true

    private var translations: [Language: [String: String]] = [:]
    private let translationService = TranslationService.shared
    private let baseKeys: [String] = []

    init() {
        loadHardcodedTranslations()

        // Load saved language preference
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }

        // Respect a saved preference; otherwise keep the default (AI translation on).
        // bool(forKey:) returns false for an unset key, which previously disabled the
        // feature on first launch despite the `= true` default above.
        if UserDefaults.standard.object(forKey: "useAITranslation") != nil {
            useAITranslation = UserDefaults.standard.bool(forKey: "useAITranslation")
        }
    }

    // MARK: - Localization

    func localize(_ key: String) -> String {
        // Try hardcoded translations first
        if let translation = translations[currentLanguage]?[key] {
            return translation
        }

        // If AI translation is enabled and we have an English base
        if useAITranslation, let englishText = translations[.english]?[key] {
            // Try to get cached AI translation
            if let cached = translationService.cacheManager.getCachedTranslation(
                text: englishText,
                sourceLanguage: .english,
                targetLanguage: currentLanguage
            ) {
                return cached
            }

            // Return English and translate in background
            Task {
                await translateKey(key, baseText: englishText)
            }
        }

        // Fallback to key or English
        return translations[.english]?[key] ?? key
    }

    func localizeAsync(_ key: String) async -> String {
        // Try hardcoded translations first
        if let translation = translations[currentLanguage]?[key] {
            return translation
        }

        // If AI translation is enabled
        if useAITranslation, let englishText = translations[.english]?[key] {
            do {
                let translation = try await translationService.translate(
                    text: englishText,
                    to: currentLanguage,
                    from: .english
                )

                // Store in memory
                if translations[currentLanguage] == nil {
                    translations[currentLanguage] = [:]
                }
                translations[currentLanguage]?[key] = translation

                return translation
            } catch {
                print("Translation error: \(error)")
            }
        }

        // Fallback to English
        return translations[.english]?[key] ?? key
    }

    // MARK: - AI Translation Loading

    func loadAITranslations() async {
        guard useAITranslation else { return }
        guard currentLanguage != .english else { return }

        // Don't reload if we have translations
        if translations[currentLanguage]?.count ?? 0 > 50 {
            return
        }

        await MainActor.run {
            isLoadingTranslations = true
        }

        // Get all English keys
        guard let englishTranslations = translations[.english] else {
            await MainActor.run {
                isLoadingTranslations = false
            }
            return
        }

        do {
            // Translate in batches
            let keys = Array(englishTranslations.keys)
            let texts = keys.compactMap { englishTranslations[$0] }

            let translatedTexts = try await translationService.translateBatch(
                texts: texts,
                to: currentLanguage,
                from: .english
            )

            // Store translations
            await MainActor.run {
                if translations[currentLanguage] == nil {
                    translations[currentLanguage] = [:]
                }

                for (index, key) in keys.enumerated() {
                    if let englishText = englishTranslations[key],
                       let translation = translatedTexts[englishText] {
                        translations[currentLanguage]?[key] = translation
                    }
                }

                isLoadingTranslations = false
            }
        } catch {
            print("Failed to load AI translations: \(error)")
            await MainActor.run {
                isLoadingTranslations = false
            }
        }
    }

    private func translateKey(_ key: String, baseText: String) async {
        do {
            let translation = try await translationService.translate(
                text: baseText,
                to: currentLanguage,
                from: .english
            )

            await MainActor.run {
                if translations[currentLanguage] == nil {
                    translations[currentLanguage] = [:]
                }
                translations[currentLanguage]?[key] = translation
            }
        } catch {
            print("Failed to translate '\(key)': \(error)")
        }
    }

    // MARK: - Language Management

    func setLanguage(_ language: Language) {
        currentLanguage = language
    }

    func toggleAITranslation(_ enabled: Bool) {
        useAITranslation = enabled
        UserDefaults.standard.set(enabled, forKey: "useAITranslation")

        if enabled {
            Task {
                await loadAITranslations()
            }
        }
    }

    // MARK: - Hardcoded Translations (Fallback)

    private func loadHardcodedTranslations() {
        // English translations (base language)
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
            "loading": "Loading...",

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
            "ai_translation": "AI Translation",
            "ai_translation_desc": "Use AI for automatic translation to any language",

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
        ]

        // Polish translations (pre-translated)
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
            "loading": "Ładowanie...",

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
            "ai_translation": "Tłumaczenie AI",
            "ai_translation_desc": "Użyj AI do automatycznego tłumaczenia na dowolny język",

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
        ]
    }
}

// MARK: - Extended Language Support

enum Language: String, CaseIterable, Identifiable {
    // European Languages
    case english = "en"
    case polish = "pl"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case russian = "ru"
    case ukrainian = "uk"
    case czech = "cs"
    case romanian = "ro"
    case greek = "el"
    case swedish = "sv"
    case norwegian = "no"
    case danish = "da"
    case finnish = "fi"
    case hungarian = "hu"
    case turkish = "tr"

    // Asian Languages
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case hindi = "hi"
    case bengali = "bn"
    case vietnamese = "vi"
    case thai = "th"
    case indonesian = "id"
    case filipino = "fil"
    case malay = "ms"

    // Middle Eastern Languages
    case arabic = "ar"
    case hebrew = "he"
    case persian = "fa"
    case urdu = "ur"

    // Other Languages
    case swahili = "sw"
    case afrikaans = "af"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        // European
        case .english: return "English"
        case .polish: return "Polski"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .dutch: return "Nederlands"
        case .russian: return "Русский"
        case .ukrainian: return "Українська"
        case .czech: return "Čeština"
        case .romanian: return "Română"
        case .greek: return "Ελληνικά"
        case .swedish: return "Svenska"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .finnish: return "Suomi"
        case .hungarian: return "Magyar"
        case .turkish: return "Türkçe"

        // Asian
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .hindi: return "हिन्दी"
        case .bengali: return "বাংলা"
        case .vietnamese: return "Tiếng Việt"
        case .thai: return "ไทย"
        case .indonesian: return "Bahasa Indonesia"
        case .filipino: return "Filipino"
        case .malay: return "Bahasa Melayu"

        // Middle Eastern
        case .arabic: return "العربية"
        case .hebrew: return "עברית"
        case .persian: return "فارسی"
        case .urdu: return "اردو"

        // Other
        case .swahili: return "Kiswahili"
        case .afrikaans: return "Afrikaans"
        }
    }

    var flag: String {
        switch self {
        // European
        case .english: return "🇬🇧"
        case .polish: return "🇵🇱"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .dutch: return "🇳🇱"
        case .russian: return "🇷🇺"
        case .ukrainian: return "🇺🇦"
        case .czech: return "🇨🇿"
        case .romanian: return "🇷🇴"
        case .greek: return "🇬🇷"
        case .swedish: return "🇸🇪"
        case .norwegian: return "🇳🇴"
        case .danish: return "🇩🇰"
        case .finnish: return "🇫🇮"
        case .hungarian: return "🇭🇺"
        case .turkish: return "🇹🇷"

        // Asian
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .hindi: return "🇮🇳"
        case .bengali: return "🇧🇩"
        case .vietnamese: return "🇻🇳"
        case .thai: return "🇹🇭"
        case .indonesian: return "🇮🇩"
        case .filipino: return "🇵🇭"
        case .malay: return "🇲🇾"

        // Middle Eastern
        case .arabic: return "🇸🇦"
        case .hebrew: return "🇮🇱"
        case .persian: return "🇮🇷"
        case .urdu: return "🇵🇰"

        // Other
        case .swahili: return "🇰🇪"
        case .afrikaans: return "🇿🇦"
        }
    }

    var isRTL: Bool {
        switch self {
        case .arabic, .hebrew, .persian, .urdu:
            return true
        default:
            return false
        }
    }
}

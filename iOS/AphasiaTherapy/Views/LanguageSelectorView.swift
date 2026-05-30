//
//  LanguageSelectorView.swift
//  AphasiaTherapy
//
//  Language selection view with support for 36+ languages
//

import SwiftUI
import UIKit

struct LanguageSelectorView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    var body: some View {
        List {
            // Search bar
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search languages...", text: $searchText)
                }
            }

            // Current language
            if searchText.isEmpty {
                Section(header: Text("Current Language")) {
                    LanguageRow(
                        language: localizationManager.currentLanguage,
                        isSelected: true
                    )
                }
            }

            // European languages
            if !europeanLanguages.isEmpty {
                Section(header: Text("European Languages")) {
                    ForEach(europeanLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language == localizationManager.currentLanguage
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectLanguage(language)
                        }
                    }
                }
            }

            // Asian languages
            if !asianLanguages.isEmpty {
                Section(header: Text("Asian Languages")) {
                    ForEach(asianLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language == localizationManager.currentLanguage
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectLanguage(language)
                        }
                    }
                }
            }

            // Middle Eastern languages
            if !middleEasternLanguages.isEmpty {
                Section(header: Text("Middle Eastern Languages")) {
                    ForEach(middleEasternLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language == localizationManager.currentLanguage
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectLanguage(language)
                        }
                    }
                }
            }

            // Other languages
            if !otherLanguages.isEmpty {
                Section(header: Text("Other Languages")) {
                    ForEach(otherLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language == localizationManager.currentLanguage
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectLanguage(language)
                        }
                    }
                }
            }

            // AI Translation info
            if localizationManager.useAITranslation {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                            Text("AI-Powered Translation")
                                .font(.headline)
                        }

                        Text("Languages marked with ✨ are automatically translated using AI technology. Translation quality may vary.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(localizationManager.localize("language_preference"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Language Groups

    private var europeanLanguages: [Language] {
        let languages: [Language] = [
            .english, .polish, .spanish, .french, .german, .italian, .portuguese,
            .dutch, .russian, .ukrainian, .czech, .romanian, .greek, .swedish,
            .norwegian, .danish, .finnish, .hungarian, .turkish
        ]
        return filteredLanguages(languages)
    }

    private var asianLanguages: [Language] {
        let languages: [Language] = [
            .chinese, .japanese, .korean, .hindi, .bengali, .vietnamese,
            .thai, .indonesian, .filipino, .malay
        ]
        return filteredLanguages(languages)
    }

    private var middleEasternLanguages: [Language] {
        let languages: [Language] = [.arabic, .hebrew, .persian, .urdu]
        return filteredLanguages(languages)
    }

    private var otherLanguages: [Language] {
        let languages: [Language] = [.swahili, .afrikaans]
        return filteredLanguages(languages)
    }

    private func filteredLanguages(_ languages: [Language]) -> [Language] {
        if searchText.isEmpty {
            return languages
        }

        return languages.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Actions

    private func selectLanguage(_ language: Language) {
        localizationManager.setLanguage(language)

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Dismiss after selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Language Row

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool

    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        HStack(spacing: 12) {
            // Flag
            Text(language.flag)
                .font(.title2)

            // Language name
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(language.displayName)
                        .font(.body)

                    // AI translation indicator
                    if needsAITranslation {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    // RTL indicator
                    if language.isRTL {
                        Image(systemName: "arrow.right.to.line")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text(language.rawValue.uppercased())
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Checkmark for selected language
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.headline)
            }
        }
        .padding(.vertical, 4)
    }

    private var needsAITranslation: Bool {
        language != .english && language != .polish && localizationManager.useAITranslation
    }
}

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LanguageSelectorView()
                .environmentObject(LocalizationManager())
        }
    }
}

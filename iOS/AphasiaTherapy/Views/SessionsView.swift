//
//  SessionsView.swift
//  AphasiaTherapy
//
//  View for browsing and starting therapy sessions
//

import SwiftUI

struct SessionsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var sessions: [TherapySession] = []
    @State private var filteredSessions: [TherapySession] = []
    @State private var isLoading = true
    @State private var selectedType: SessionType?
    @State private var selectedDifficulty: Difficulty?
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search sessions...", text: $searchText)
                        .onChange(of: searchText) { _ in
                            filterSessions()
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Type filters
                        ForEach([nil] + SessionType.allCases.map { $0 as SessionType? }, id: \.self) { type in
                            FilterChip(
                                title: type?.displayName ?? "All",
                                isSelected: selectedType == type
                            ) {
                                selectedType = type
                                filterSessions()
                            }
                        }

                        Divider()
                            .frame(height: 30)

                        // Difficulty filters
                        ForEach([nil] + Difficulty.allCases.map { $0 as Difficulty? }, id: \.self) { difficulty in
                            FilterChip(
                                title: difficulty?.displayName ?? "All",
                                isSelected: selectedDifficulty == difficulty,
                                color: difficulty == nil ? .blue : Color(difficulty!.color)
                            ) {
                                selectedDifficulty = difficulty
                                filterSessions()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Sessions list
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredSessions.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No sessions found")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredSessions) { session in
                                NavigationLink(destination: ExerciseSessionView(session: session)) {
                                    SessionCard(session: session)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(localizationManager.localize("sessions"))
            .onAppear {
                loadSessions()
            }
            .refreshable {
                loadSessions()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func loadSessions() {
        guard let token = authManager.authToken else { return }

        Task {
            do {
                let loadedSessions = try await apiClient.getTherapySessions(
                    token: token,
                    language: localizationManager.currentLanguage.rawValue
                )

                await MainActor.run {
                    self.sessions = loadedSessions
                    filterSessions()
                    self.isLoading = false
                }
            } catch {
                print("Error loading sessions: \(error)")
                isLoading = false
            }
        }
    }

    private func filterSessions() {
        var filtered = sessions

        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }

        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredSessions = filtered
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: TherapySession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                Image(systemName: session.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 5) {
                    Text(session.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(session.type.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Difficulty badge
                Text(session.difficulty.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(session.difficulty.color).opacity(0.2))
                    .foregroundColor(Color(session.difficulty.color))
                    .cornerRadius(8)
            }

            Text(session.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Label("\(session.exercises.count) exercises", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Label("\(session.estimatedDuration) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - SessionType Extension

extension SessionType: CaseIterable {
    static var allCases: [SessionType] {
        [.wordNaming, .sentenceCompletion, .comprehension, .repetition, .reading, .writing]
    }
}

// MARK: - Difficulty Extension

extension Difficulty: CaseIterable {
    static var allCases: [Difficulty] {
        [.beginner, .intermediate, .advanced]
    }
}

extension Color {
    init(_ colorName: String) {
        switch colorName {
        case "green": self = .green
        case "orange": self = .orange
        case "red": self = .red
        case "blue": self = .blue
        default: self = .gray
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

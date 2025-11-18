//
//  HomeView.swift
//  AphasiaTherapy
//
//  Home screen with welcome message and quick actions
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var userProgress: UserProgress?
    @State private var recentSessions: [SessionHistory] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Welcome header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(localizationManager.localize("welcome")), \(authManager.currentUser?.name ?? "")")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Stats cards
                    if let progress = userProgress {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(
                                title: localizationManager.localize("current_streak"),
                                value: "\(progress.streak)",
                                subtitle: localizationManager.localize("days"),
                                icon: "flame.fill",
                                color: .orange
                            )

                            StatCard(
                                title: localizationManager.localize("average_score"),
                                value: "\(Int(progress.averageScore))%",
                                subtitle: localizationManager.localize("completed_sessions"),
                                icon: "star.fill",
                                color: .yellow
                            )

                            StatCard(
                                title: localizationManager.localize("total_sessions"),
                                value: "\(progress.completedSessions)",
                                subtitle: localizationManager.localize("sessions"),
                                icon: "checkmark.circle.fill",
                                color: .green
                            )

                            StatCard(
                                title: localizationManager.localize("time_spent"),
                                value: formatTime(progress.totalTimeSpent),
                                subtitle: localizationManager.localize("minutes"),
                                icon: "clock.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Quick actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text(localizationManager.localize("start_new"))
                            .font(.headline)
                            .padding(.horizontal)

                        NavigationLink(destination: SessionsView()) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text(localizationManager.localize("start_new"))
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)

                    // Recent sessions
                    if !recentSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(localizationManager.localize("recent_sessions"))
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(recentSessions.prefix(5)) { session in
                                RecentSessionCard(session: session)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadData()
            }
            .refreshable {
                loadData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)"
        } else {
            let hours = minutes / 60
            return "\(hours)h \(minutes % 60)m"
        }
    }

    private func loadData() {
        guard let token = authManager.authToken else { return }

        Task {
            do {
                let progress = try await apiClient.getUserProgress(token: token)
                await MainActor.run {
                    self.userProgress = progress
                    self.recentSessions = progress.sessionHistory
                    self.isLoading = false
                }
            } catch {
                print("Error loading progress: \(error)")
                isLoading = false
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Recent Session Card

struct RecentSessionCard: View {
    let session: SessionHistory

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(session.sessionName)
                    .font(.headline)

                Text(formatDate(session.completedAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("\(Int(session.score))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("\(session.exercisesCompleted) exercises")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

//
//  ProgressView.swift
//  AphasiaTherapy
//
//  View for displaying user progress and statistics
//

import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var userProgress: UserProgress?
    @State private var isLoading = true
    @State private var selectedTimeRange: TimeRange = .week

    var body: some View {
        NavigationView {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let progress = userProgress {
                    VStack(spacing: 25) {
                        // Overview cards
                        VStack(spacing: 15) {
                            HStack(spacing: 15) {
                                ProgressCard(
                                    title: localizationManager.localize("total_sessions"),
                                    value: "\(progress.completedSessions)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )

                                ProgressCard(
                                    title: localizationManager.localize("average_score"),
                                    value: "\(Int(progress.averageScore))%",
                                    icon: "star.fill",
                                    color: .yellow
                                )
                            }

                            HStack(spacing: 15) {
                                ProgressCard(
                                    title: localizationManager.localize("current_streak"),
                                    value: "\(progress.streak) days",
                                    icon: "flame.fill",
                                    color: .orange
                                )

                                ProgressCard(
                                    title: localizationManager.localize("time_spent"),
                                    value: formatTime(progress.totalTimeSpent),
                                    icon: "clock.fill",
                                    color: .blue
                                )
                            }
                        }
                        .padding()

                        // Performance chart
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(localizationManager.localize("performance_chart"))
                                    .font(.headline)

                                Spacer()

                                Picker("", selection: $selectedTimeRange) {
                                    ForEach(TimeRange.allCases) { range in
                                        Text(range.displayName).tag(range)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
                            }
                            .padding(.horizontal)

                            if #available(iOS 16.0, *) {
                                PerformanceChartView(sessions: getFilteredSessions(progress.sessionHistory))
                                    .frame(height: 250)
                                    .padding()
                            } else {
                                LegacyChartView(sessions: getFilteredSessions(progress.sessionHistory))
                                    .frame(height: 250)
                                    .padding()
                            }
                        }
                        .padding(.vertical)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal)

                        // Performance by type
                        if !progress.performanceByType.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Performance by Type")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(Array(progress.performanceByType.keys.sorted()), id: \.self) { type in
                                    if let performance = progress.performanceByType[type] {
                                        TypePerformanceRow(type: type, performance: performance)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }

                        // Session history
                        VStack(alignment: .leading, spacing: 15) {
                            Text(localizationManager.localize("session_history"))
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(progress.sessionHistory.prefix(10)) { session in
                                SessionHistoryRow(session: session)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.bottom, 30)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(localizationManager.localize("no_progress_yet"))
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                }
            }
            .navigationTitle(localizationManager.localize("progress"))
            .onAppear {
                loadProgress()
            }
            .refreshable {
                loadProgress()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func loadProgress() {
        guard let token = authManager.authToken else {
            // Guest / offline → locally-stored practice progress.
            let local = LocalProgressStore.shared.userProgress()
            self.userProgress = local.completedSessions > 0 ? local : nil
            self.isLoading = false
            return
        }

        Task {
            do {
                let progress = try await apiClient.getUserProgress(token: token)
                await MainActor.run {
                    self.userProgress = progress
                    self.isLoading = false
                }
            } catch {
                print("Error loading progress: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    private func getFilteredSessions(_ sessions: [SessionHistory]) -> [SessionHistory] {
        let calendar = Calendar.current
        let now = Date()

        return sessions.filter { session in
            switch selectedTimeRange {
            case .week:
                return calendar.dateComponents([.day], from: session.completedAt, to: now).day ?? 0 <= 7
            case .month:
                return calendar.dateComponents([.day], from: session.completedAt, to: now).day ?? 0 <= 30
            case .year:
                return calendar.dateComponents([.day], from: session.completedAt, to: now).day ?? 0 <= 365
            case .all:
                return true
            }
        }
    }
}

// MARK: - Progress Card

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Performance Chart View (iOS 16+)

@available(iOS 16.0, *)
struct PerformanceChartView: View {
    let sessions: [SessionHistory]

    var body: some View {
        Chart {
            ForEach(sessions) { session in
                LineMark(
                    x: .value("Date", session.completedAt),
                    y: .value("Score", session.score)
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value("Date", session.completedAt),
                    y: .value("Score", session.score)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
    }
}

// MARK: - Legacy Chart View (iOS 15 and below)

struct LegacyChartView: View {
    let sessions: [SessionHistory]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Divider()
                        Spacer()
                    }
                }

                // Data points and line
                Path { path in
                    guard !sessions.isEmpty else { return }

                    let sortedSessions = sessions.sorted { $0.completedAt < $1.completedAt }
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let xStep = width / CGFloat(max(sortedSessions.count - 1, 1))

                    for (index, session) in sortedSessions.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = height - (CGFloat(session.score) / 100.0 * height)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                // Points
                ForEach(Array(sessions.sorted { $0.completedAt < $1.completedAt }.enumerated()), id: \.element.id) { index, session in
                    let sortedSessions = sessions.sorted { $0.completedAt < $1.completedAt }
                    let xStep = geometry.size.width / CGFloat(max(sortedSessions.count - 1, 1))
                    let x = CGFloat(index) * xStep
                    let y = geometry.size.height - (CGFloat(session.score) / 100.0 * geometry.size.height)

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Type Performance Row

struct TypePerformanceRow: View {
    let type: String
    let performance: TypePerformance

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(type)
                    .font(.headline)

                Spacer()

                Text("\(Int(performance.averageScore))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            HStack {
                Text("\(performance.sessionsCompleted) sessions")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                if performance.improvement > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                        Text("+\(Int(performance.improvement))%")
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Session History Row

struct SessionHistoryRow: View {
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

                Text("\(formatTime(session.timeSpent))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes)m"
    }
}

// MARK: - Time Range

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

struct ProgressDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressDashboardView()
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

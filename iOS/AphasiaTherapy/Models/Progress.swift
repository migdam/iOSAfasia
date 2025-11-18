//
//  Progress.swift
//  AphasiaTherapy
//
//  User progress tracking models
//

import Foundation

struct UserProgress: Codable {
    var totalSessions: Int
    var completedSessions: Int
    var averageScore: Double
    var totalTimeSpent: Int // in seconds
    var streak: Int
    var lastSessionDate: Date?
    var sessionHistory: [SessionHistory]
    var performanceByType: [String: TypePerformance]

    enum CodingKeys: String, CodingKey {
        case totalSessions = "total_sessions"
        case completedSessions = "completed_sessions"
        case averageScore = "average_score"
        case totalTimeSpent = "total_time_spent"
        case streak
        case lastSessionDate = "last_session_date"
        case sessionHistory = "session_history"
        case performanceByType = "performance_by_type"
    }
}

struct SessionHistory: Codable, Identifiable {
    let id: String
    var sessionName: String
    var score: Double
    var completedAt: Date
    var timeSpent: Int
    var exercisesCompleted: Int

    enum CodingKeys: String, CodingKey {
        case id
        case sessionName = "session_name"
        case score
        case completedAt = "completed_at"
        case timeSpent = "time_spent"
        case exercisesCompleted = "exercises_completed"
    }
}

struct TypePerformance: Codable {
    var sessionsCompleted: Int
    var averageScore: Double
    var totalTimeSpent: Int
    var improvement: Double

    enum CodingKeys: String, CodingKey {
        case sessionsCompleted = "sessions_completed"
        case averageScore = "average_score"
        case totalTimeSpent = "total_time_spent"
        case improvement
    }
}

struct ProgressChartData: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let sessionType: String
}

struct StreakData {
    let currentStreak: Int
    let longestStreak: Int
    let lastSessionDate: Date?

    var isActiveToday: Bool {
        guard let lastDate = lastSessionDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}

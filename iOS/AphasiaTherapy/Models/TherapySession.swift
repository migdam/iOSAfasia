//
//  TherapySession.swift
//  AphasiaTherapy
//
//  Therapy session data models
//

import Foundation

struct TherapySession: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var type: SessionType
    var difficulty: Difficulty
    var exercises: [Exercise]
    var estimatedDuration: Int // in minutes
    var language: String
    var imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case difficulty
        case exercises
        case estimatedDuration = "estimated_duration"
        case language
        case imageURL = "image_url"
    }
}

enum SessionType: String, Codable {
    case wordNaming = "word_naming"
    case sentenceCompletion = "sentence_completion"
    case comprehension = "comprehension"
    case repetition = "repetition"
    case reading = "reading"
    case writing = "writing"

    var displayName: String {
        switch self {
        case .wordNaming: return "Word Naming"
        case .sentenceCompletion: return "Sentence Completion"
        case .comprehension: return "Comprehension"
        case .repetition: return "Repetition"
        case .reading: return "Reading"
        case .writing: return "Writing"
        }
    }

    var icon: String {
        switch self {
        case .wordNaming: return "text.bubble"
        case .sentenceCompletion: return "text.quote"
        case .comprehension: return "ear"
        case .repetition: return "arrow.triangle.2.circlepath"
        case .reading: return "book"
        case .writing: return "pencil"
        }
    }
}

enum Difficulty: String, Codable {
    case beginner
    case intermediate
    case advanced

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

struct Exercise: Codable, Identifiable {
    let id: String
    var prompt: String
    var type: ExerciseType
    var options: [String]?
    var correctAnswer: String?
    var imageURL: String?
    var audioURL: String?
    var hints: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case prompt
        case type
        case options
        case correctAnswer = "correct_answer"
        case imageURL = "image_url"
        case audioURL = "audio_url"
        case hints
    }
}

enum ExerciseType: String, Codable {
    case multipleChoice = "multiple_choice"
    case fillInBlank = "fill_in_blank"
    case voiceResponse = "voice_response"
    case matching = "matching"
    case sequencing = "sequencing"
}

struct SessionProgress: Codable, Identifiable {
    let id: String
    var sessionId: String
    var userId: String
    var score: Double
    var completedExercises: Int
    var totalExercises: Int
    var timeSpent: Int // in seconds
    var completedAt: Date
    var answers: [ExerciseAnswer]

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case userId = "user_id"
        case score
        case completedExercises = "completed_exercises"
        case totalExercises = "total_exercises"
        case timeSpent = "time_spent"
        case completedAt = "completed_at"
        case answers
    }

    var percentageComplete: Double {
        guard totalExercises > 0 else { return 0 }
        return (Double(completedExercises) / Double(totalExercises)) * 100
    }
}

struct ExerciseAnswer: Codable {
    var exerciseId: String
    var userAnswer: String
    var isCorrect: Bool
    var timeSpent: Int // in seconds

    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case userAnswer = "user_answer"
        case isCorrect = "is_correct"
        case timeSpent = "time_spent"
    }
}

struct ProgressSubmission: Codable {
    let sessionId: String
    let score: Double
    let completedExercises: Int
    let totalExercises: Int
    let timeSpent: Int
    let answers: [ExerciseAnswer]

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case score
        case completedExercises = "completed_exercises"
        case totalExercises = "total_exercises"
        case timeSpent = "time_spent"
        case answers
    }
}

//
//  LocalContent.swift
//  AphasiaTherapy
//
//  Built-in practice content and a local progress store.
//
//  These power the no-login "Practice without an account" mode and act as an
//  offline fallback, so the app is usable without a backend and a screen is never
//  a dead loading spinner. Requiring an account (email + password) is a real access
//  barrier for people with writing/memory deficits, so a zero-friction practice
//  path matters clinically.
//

import Foundation

// MARK: - Sample Content

enum SampleContent {
    /// A small, self-contained set of sessions. English only for now; per-language
    /// therapy content must be authored/validated by a fluent clinician rather than
    /// machine-translated.
    static func sessions(language: String = "en") -> [TherapySession] {
        [namingSession, comprehensionSession, completionSession]
    }

    private static let namingSession = TherapySession(
        id: "sample-naming",
        name: "Everyday Naming",
        description: "Name common objects. Use the hints if a word is on the tip of your tongue.",
        type: .wordNaming,
        difficulty: .beginner,
        exercises: [
            Exercise(
                id: "naming-1",
                prompt: "What do you call the yellow fruit that you peel?",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "banana",
                imageURL: nil,
                audioURL: nil,
                hints: ["It is a fruit.", "Monkeys like to eat it.", "It is long and curved."]
            ),
            Exercise(
                id: "naming-2",
                prompt: "What is the pet that says \u{201C}meow\u{201D}?",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "cat",
                imageURL: nil,
                audioURL: nil,
                hints: ["It is a small pet.", "It purrs when happy.", "It chases mice."]
            ),
            Exercise(
                id: "naming-3",
                prompt: "What do you use to unlock a door?",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "key",
                imageURL: nil,
                audioURL: nil,
                hints: ["It is small and made of metal.", "It fits in a lock."]
            )
        ],
        estimatedDuration: 5,
        language: "en",
        imageURL: nil
    )

    private static let comprehensionSession = TherapySession(
        id: "sample-comprehension",
        name: "Listen and Choose",
        description: "Tap the Listen button, then choose the best answer.",
        type: .comprehension,
        difficulty: .beginner,
        exercises: [
            Exercise(
                id: "comp-1",
                prompt: "Which one can you drink?",
                type: .multipleChoice,
                options: ["Chair", "Water", "Shoe", "Book"],
                correctAnswer: "Water",
                imageURL: nil,
                audioURL: nil,
                hints: ["You reach for it when you are thirsty."]
            ),
            Exercise(
                id: "comp-2",
                prompt: "Which one do you sleep in?",
                type: .multipleChoice,
                options: ["Bed", "Spoon", "Car", "Hat"],
                correctAnswer: "Bed",
                imageURL: nil,
                audioURL: nil,
                hints: ["You use it at night."]
            ),
            Exercise(
                id: "comp-3",
                prompt: "Which one tells the time?",
                type: .multipleChoice,
                options: ["Clock", "Apple", "Sock", "Door"],
                correctAnswer: "Clock",
                imageURL: nil,
                audioURL: nil,
                hints: ["It has hands that move, or shows numbers."]
            )
        ],
        estimatedDuration: 5,
        language: "en",
        imageURL: nil
    )

    private static let completionSession = TherapySession(
        id: "sample-completion",
        name: "Finish the Sentence",
        description: "Complete each sentence with the missing word.",
        type: .sentenceCompletion,
        difficulty: .intermediate,
        exercises: [
            Exercise(
                id: "compl-1",
                prompt: "Finish the sentence: I write with a ___.",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "pen",
                imageURL: nil,
                audioURL: nil,
                hints: ["It has ink inside.", "You hold it to write."]
            ),
            Exercise(
                id: "compl-2",
                prompt: "Finish the sentence: You wear shoes on your ___.",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "feet",
                imageURL: nil,
                audioURL: nil,
                hints: ["They are parts of your body.", "You have two of them at the bottom of your legs."]
            ),
            Exercise(
                id: "compl-3",
                prompt: "Finish the sentence: At night I can see the moon and the ___.",
                type: .fillInBlank,
                options: nil,
                correctAnswer: "stars",
                imageURL: nil,
                audioURL: nil,
                hints: ["They twinkle in the sky.", "There are many of them at night."]
            )
        ],
        estimatedDuration: 5,
        language: "en",
        imageURL: nil
    )
}

// MARK: - Local Progress Store

/// Persists locally-completed sessions (guest / offline) so Home and Progress can
/// show real stats without a backend account.
final class LocalProgressStore {
    static let shared = LocalProgressStore()

    private let key = "local_progress_history"
    private let defaults = UserDefaults.standard

    private init() {}

    func record(sessionName: String, score: Double, timeSpent: Int, exercisesCompleted: Int) {
        var history = loadHistory()
        let entry = SessionHistory(
            id: UUID().uuidString,
            sessionName: sessionName,
            score: score,
            completedAt: Date(),
            timeSpent: timeSpent,
            exercisesCompleted: exercisesCompleted
        )
        history.insert(entry, at: 0)
        if history.count > 100 { history = Array(history.prefix(100)) }
        defaults.setCodable(history, forKey: key)
    }

    func loadHistory() -> [SessionHistory] {
        let history: [SessionHistory] = defaults.codable(forKey: key) ?? []
        return history
    }

    /// Builds a `UserProgress` snapshot from locally-stored history.
    func userProgress() -> UserProgress {
        let history = loadHistory()
        let completed = history.count
        let averageScore = completed == 0 ? 0 : history.map(\.score).reduce(0, +) / Double(completed)
        let totalTime = history.map(\.timeSpent).reduce(0, +)

        return UserProgress(
            totalSessions: completed,
            completedSessions: completed,
            averageScore: averageScore,
            totalTimeSpent: totalTime,
            streak: computeStreak(history),
            lastSessionDate: history.first?.completedAt,
            sessionHistory: history,
            performanceByType: [:]
        )
    }

    /// Counts consecutive days (ending today or yesterday) that contain a session.
    private func computeStreak(_ history: [SessionHistory]) -> Int {
        guard !history.isEmpty else { return 0 }
        let calendar = Calendar.current
        let days = Set(history.map { calendar.startOfDay(for: $0.completedAt) })

        var day = calendar.startOfDay(for: Date())
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}

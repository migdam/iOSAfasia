//
//  TherapyEngine.swift
//  AphasiaTherapy
//
//  Clinically-informed answer scoring and a graduated cueing hierarchy.
//
//  People with aphasia routinely produce near-misses (phonemic/semantic
//  paraphasias, self-corrections, spelling slips). Exact-string matching scores
//  those as failures, which is both inaccurate and demoralizing. And effective
//  naming therapy provides *graduated cues to elicit* a word, rather than a single
//  hint after failure. These two helpers implement both ideas.
//

import Foundation

// MARK: - Answer Evaluation

enum AnswerAccuracy {
    case correct       // exact match after normalization
    case approximate   // close enough to credit (near-miss / self-correction)
    case incorrect

    /// Whether the response should be credited toward the score.
    var isCredited: Bool { self != .incorrect }
}

enum AnswerEvaluator {
    /// Compares a typed or selected answer against the target, tolerating the
    /// near-misses people with aphasia commonly produce: case, accents,
    /// punctuation, minor spelling/phonemic slips, and self-corrections.
    static func evaluate(_ userAnswer: String, against correctAnswer: String) -> AnswerAccuracy {
        let user = normalize(userAnswer)
        let target = normalize(correctAnswer)

        guard !user.isEmpty, !target.isEmpty else { return .incorrect }
        if user == target { return .correct }

        // Self-correction or extra words: "it is a cake" contains the target "cake".
        if containsWholeWord(target, in: user) { return .approximate }

        // Phonemic / spelling approximation: small edit distance relative to length.
        let tolerance = max(1, Int((Double(target.count) * 0.25).rounded()))
        if levenshtein(user, target) <= tolerance { return .approximate }

        return .incorrect
    }

    // MARK: Normalization

    /// Lowercases, strips diacritics, and reduces any run of non-alphanumerics to a
    /// single space so punctuation and accents don't cause false negatives.
    static func normalize(_ s: String) -> String {
        let folded = s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        var result = ""
        for scalar in folded.unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                result.unicodeScalars.append(scalar)
            } else {
                result.append(" ")
            }
        }
        return result.split(separator: " ").joined(separator: " ")
    }

    private static func containsWholeWord(_ word: String, in phrase: String) -> Bool {
        guard !word.isEmpty else { return false }
        return phrase.split(separator: " ").map(String.init).contains(word)
    }

    // MARK: Levenshtein edit distance

    static func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = min(
                    previous[j] + 1,        // deletion
                    current[j - 1] + 1,     // insertion
                    previous[j - 1] + cost  // substitution
                )
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }
}

// MARK: - Cueing Hierarchy

/// A single cue, ordered from least to most revealing.
struct Cue: Identifiable {
    enum Kind {
        case semantic, phonemic, syllable, partialSpelling, wholeWord
    }

    /// Stable, content-derived id so SwiftUI can diff cues across renders.
    var id: String { "\(kind)-\(text)" }
    let kind: Kind
    let label: String   // short heading, e.g. "First sound"
    let text: String    // the cue shown to the user
    let speakable: Bool // whether a "listen" affordance makes sense
}

enum CueGenerator {
    /// Builds a graduated set of cues (least → most revealing) that mirror the
    /// cueing hierarchies SLPs use to *elicit* a target word.
    static func cues(for exercise: Exercise) -> [Cue] {
        var cues: [Cue] = []

        // 1. Semantic cue — prefer author-provided hints (meaning / use / category).
        let hints = (exercise.hints ?? []).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if let first = hints.first {
            cues.append(Cue(kind: .semantic, label: "Meaning", text: first, speakable: true))
        }

        guard let answer = exercise.correctAnswer?.trimmingCharacters(in: .whitespacesAndNewlines),
              !answer.isEmpty else {
            // Without a known target, the most we can offer is any remaining hints.
            for extra in hints.dropFirst() {
                cues.append(Cue(kind: .semantic, label: "Clue", text: extra, speakable: true))
            }
            return cues
        }

        // 2. Phonemic cue — the initial sound / letter.
        if let initial = answer.first {
            cues.append(Cue(kind: .phonemic,
                            label: "First sound",
                            text: "It starts with \u{201C}\(String(initial).uppercased())\u{201D}.",
                            speakable: true))
        }

        // 3. Syllable cue — number of beats.
        let beats = syllableCount(answer)
        if beats > 0 {
            cues.append(Cue(kind: .syllable,
                            label: "Beats",
                            text: beats == 1 ? "It has 1 beat (syllable)."
                                             : "It has \(beats) beats (syllables).",
                            speakable: false))
        }

        // 4. Partial spelling — reveal roughly the first half.
        cues.append(Cue(kind: .partialSpelling,
                        label: "Letters",
                        text: maskedSpelling(answer),
                        speakable: false))

        // 5. Whole word — model the target to repeat aloud.
        cues.append(Cue(kind: .wholeWord,
                        label: "The word",
                        text: "The word is \u{201C}\(answer)\u{201D}. Try saying it.",
                        speakable: true))

        return cues
    }

    /// Approximate English syllable count (vowel-group heuristic). Good enough for a
    /// "number of beats" cue; not a linguistic guarantee.
    static func syllableCount(_ word: String) -> Int {
        let vowels = Set("aeiouy")
        let lower = word.lowercased()
        var count = 0
        var previousWasVowel = false
        for ch in lower {
            let isVowel = vowels.contains(ch)
            if isVowel && !previousWasVowel { count += 1 }
            previousWasVowel = isVowel
        }
        if lower.hasSuffix("e") && count > 1 { count -= 1 } // silent trailing 'e'
        let hasLetters = lower.contains { $0.isLetter }
        return max(count, hasLetters ? 1 : 0)
    }

    /// Shows the first ~half of the letters and masks the rest: "cake" -> "c a _ _".
    static func maskedSpelling(_ word: String) -> String {
        let chars = Array(word)
        let reveal = max(1, chars.count / 2)
        var parts: [String] = []
        for (index, ch) in chars.enumerated() {
            if ch == " " {
                parts.append("/")
            } else {
                parts.append(index < reveal ? String(ch) : "_")
            }
        }
        return parts.joined(separator: " ")
    }
}

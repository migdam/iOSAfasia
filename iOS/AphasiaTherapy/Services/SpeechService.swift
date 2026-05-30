//
//  SpeechService.swift
//  AphasiaTherapy
//
//  Text-to-speech (read-aloud) support.
//
//  Reading prompts and answer options aloud is essential for users with alexia,
//  auditory/reading comprehension deficits, or low literacy — all common in
//  aphasia. It also enables true auditory-comprehension tasks (hear it, choose it).
//

import Foundation
import AVFoundation

final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        configureAudioSession()
    }

    /// Speaks the given text. `languageCode` is a `Language.rawValue` (e.g. "en", "pl").
    func speak(_ text: String, languageCode: String = "en") {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Interrupt anything already playing so repeated taps feel responsive.
        stop()

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = voice(for: languageCode)
        // Slightly slower than default, with a short lead-in pause; people with
        // aphasia benefit from a reduced rate.
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.preUtteranceDelay = 0.1
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Private

    private func voice(for languageCode: String) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice(language: Self.bcp47(for: languageCode))
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    private func configureAudioSession() {
        #if os(iOS)
        // Speak even when the ringer is silent, and lower (rather than stop) other audio.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        #endif
    }

    /// Maps a `Language.rawValue` to a BCP-47 locale that `AVSpeechSynthesisVoice` understands.
    static func bcp47(for code: String) -> String {
        switch code {
        case "en": return "en-US"
        case "pl": return "pl-PL"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "pt": return "pt-PT"
        case "nl": return "nl-NL"
        case "ru": return "ru-RU"
        case "uk": return "uk-UA"
        case "cs": return "cs-CZ"
        case "ro": return "ro-RO"
        case "el": return "el-GR"
        case "sv": return "sv-SE"
        case "no": return "nb-NO"
        case "da": return "da-DK"
        case "fi": return "fi-FI"
        case "hu": return "hu-HU"
        case "tr": return "tr-TR"
        case "zh": return "zh-CN"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "hi": return "hi-IN"
        case "th": return "th-TH"
        case "vi": return "vi-VN"
        case "id": return "id-ID"
        case "ar": return "ar-SA"
        case "he": return "he-IL"
        default: return code
        }
    }
}

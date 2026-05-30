//
//  ExerciseSessionView.swift
//  AphasiaTherapy
//
//  View for completing therapy session exercises.
//
//  Designed around how aphasia is actually treated:
//   - prompts and options can be read aloud (alexia / comprehension support),
//   - answers are scored with tolerance for normal aphasic near-misses,
//   - a graduated cueing hierarchy helps *elicit* the word before failure.
//

import SwiftUI

struct ExerciseSessionView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode

    let session: TherapySession

    @State private var exercises: [Exercise] = []
    @State private var currentExerciseIndex = 0
    @State private var userAnswers: [String] = []
    @State private var exerciseResults: [ExerciseAnswer] = []
    @State private var startTime = Date()
    @State private var exerciseStartTime = Date()
    @State private var showResult = false
    @State private var lastAccuracy: AnswerAccuracy = .incorrect
    @State private var selectedAnswer = ""
    @State private var isLoading = true
    @State private var showCompletionView = false

    // Cueing hierarchy state.
    @State private var revealedCueCount = 0
    @State private var totalCuesUsed = 0

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if showCompletionView {
                SessionCompletionView(
                    session: session,
                    results: exerciseResults,
                    totalTime: Int(Date().timeIntervalSince(startTime)),
                    cuesUsed: totalCuesUsed
                )
            } else if currentExerciseIndex < exercises.count {
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressBar(current: currentExerciseIndex + 1, total: exercises.count)
                        .padding()

                    ScrollView {
                        VStack(spacing: 25) {
                            // Exercise content
                            ExerciseContentView(
                                exercise: exercises[currentExerciseIndex],
                                selectedAnswer: $selectedAnswer,
                                showResult: showResult,
                                accuracy: lastAccuracy,
                                revealedCueCount: $revealedCueCount
                            )

                            // Action buttons
                            VStack(spacing: 12) {
                                if !showResult {
                                    Button(action: checkAnswer) {
                                        Text(localizationManager.localize("check_answer"))
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(selectedAnswer.isEmpty ? Color.gray : Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                    .disabled(selectedAnswer.isEmpty)

                                    Button(action: skipExercise) {
                                        Text(localizationManager.localize("skip"))
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                    }
                                } else {
                                    Button(action: nextExercise) {
                                        Text(currentExerciseIndex < exercises.count - 1 ?
                                             localizationManager.localize("next") :
                                             localizationManager.localize("finish_session"))
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    SpeechService.shared.stop()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            loadExercises()
        }
        .onDisappear {
            SpeechService.shared.stop()
        }
    }

    private func loadExercises() {
        guard let token = authManager.authToken else {
            // Guest / offline → use the exercises the session already carries.
            useEmbeddedExercises()
            return
        }

        Task {
            do {
                let loadedExercises = try await apiClient.getSessionExercises(
                    token: token,
                    sessionId: session.id
                )

                await MainActor.run {
                    self.exercises = loadedExercises
                    self.userAnswers = Array(repeating: "", count: loadedExercises.count)
                    self.isLoading = false
                    self.startTime = Date()
                    self.exerciseStartTime = Date()
                }
            } catch {
                print("Error loading exercises: \(error)")
                await MainActor.run { self.useEmbeddedExercises() }
            }
        }
    }

    /// Falls back to the exercises embedded in the session (sample/offline content).
    private func useEmbeddedExercises() {
        self.exercises = session.exercises
        self.userAnswers = Array(repeating: "", count: session.exercises.count)
        self.isLoading = false
        self.startTime = Date()
        self.exerciseStartTime = Date()
    }

    private func checkAnswer() {
        let currentExercise = exercises[currentExerciseIndex]
        let timeSpent = Int(Date().timeIntervalSince(exerciseStartTime))

        // Tolerant scoring: credit exact matches, self-corrections and near-misses.
        if let target = currentExercise.correctAnswer, !target.isEmpty {
            lastAccuracy = AnswerEvaluator.evaluate(selectedAnswer, against: target)
        } else {
            // No answer key (e.g. open production) — credit any genuine attempt.
            lastAccuracy = selectedAnswer.trimmingCharacters(in: .whitespaces).isEmpty ? .incorrect : .approximate
        }

        let result = ExerciseAnswer(
            exerciseId: currentExercise.id,
            userAnswer: selectedAnswer,
            isCorrect: lastAccuracy.isCredited,
            timeSpent: timeSpent
        )
        exerciseResults.append(result)
        showResult = true

        // After an error, advance one step in the cueing hierarchy.
        if lastAccuracy == .incorrect {
            let cueCount = CueGenerator.cues(for: currentExercise).count
            if revealedCueCount < cueCount { revealedCueCount += 1 }
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(lastAccuracy == .incorrect ? .error : .success)
    }

    private func nextExercise() {
        SpeechService.shared.stop()
        totalCuesUsed += revealedCueCount
        revealedCueCount = 0

        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            selectedAnswer = ""
            showResult = false
            exerciseStartTime = Date()
        } else {
            completeSession()
        }
    }

    private func skipExercise() {
        let timeSpent = Int(Date().timeIntervalSince(exerciseStartTime))
        let currentExercise = exercises[currentExerciseIndex]

        let result = ExerciseAnswer(
            exerciseId: currentExercise.id,
            userAnswer: "",
            isCorrect: false,
            timeSpent: timeSpent
        )

        exerciseResults.append(result)
        nextExercise()
    }

    private func completeSession() {
        let totalTime = Int(Date().timeIntervalSince(startTime))
        let correctAnswers = exerciseResults.filter { $0.isCorrect }.count
        let score = exercises.isEmpty ? 0 : Double(correctAnswers) / Double(exercises.count) * 100

        guard let token = authManager.authToken else {
            // Guest / offline → store progress locally so Home and Progress update.
            LocalProgressStore.shared.record(
                sessionName: session.name,
                score: score,
                timeSpent: totalTime,
                exercisesCompleted: exerciseResults.count
            )
            showCompletionView = true
            return
        }

        let progressSubmission = ProgressSubmission(
            sessionId: session.id,
            score: score,
            completedExercises: exercises.count,
            totalExercises: exercises.count,
            timeSpent: totalTime,
            answers: exerciseResults
        )

        Task {
            do {
                _ = try await apiClient.submitSessionProgress(
                    token: token,
                    sessionId: session.id,
                    progress: progressSubmission
                )

                await MainActor.run {
                    showCompletionView = true
                }
            } catch {
                print("Error submitting progress: \(error)")
                await MainActor.run { self.showCompletionView = true }
            }
        }
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(current) of \(total)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                Text("\(Int(Double(current) / Double(total) * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (Double(current) / Double(total)), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut, value: current)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Exercise Content View

struct ExerciseContentView: View {
    @EnvironmentObject var localizationManager: LocalizationManager

    let exercise: Exercise
    @Binding var selectedAnswer: String
    let showResult: Bool
    let accuracy: AnswerAccuracy
    @Binding var revealedCueCount: Int

    private var languageCode: String { localizationManager.currentLanguage.rawValue }
    private var cues: [Cue] { CueGenerator.cues(for: exercise) }

    var body: some View {
        VStack(spacing: 25) {
            // Exercise prompt (with read-aloud)
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(localizationManager.localize("question"))
                        .font(.headline)
                        .foregroundColor(.gray)

                    Spacer()

                    Button {
                        SpeechService.shared.speak(exercise.prompt, languageCode: languageCode)
                    } label: {
                        Label(localizationManager.localize("listen"), systemImage: "speaker.wave.2.fill")
                            .font(.subheadline)
                    }
                }

                Text(exercise.prompt)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)

            // Exercise image (if available)
            if let imageURL = exercise.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .overlay(
                            ProgressView()
                        )
                }
            }

            // Answer options
            if let options = exercise.options {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        AnswerOptionButton(
                            text: option,
                            isSelected: selectedAnswer == option,
                            showResult: showResult,
                            isCorrect: option == exercise.correctAnswer,
                            languageCode: languageCode,
                            action: {
                                if !showResult {
                                    selectedAnswer = option
                                }
                            }
                        )
                    }
                }
            } else {
                // Text input for fill-in-blank
                TextField(localizationManager.localize("your_answer"), text: $selectedAnswer)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .disabled(showResult)
            }

            // Result feedback (Correct / Almost / Incorrect)
            if showResult {
                HStack(spacing: 12) {
                    Image(systemName: feedbackIcon)
                        .font(.title2)
                        .foregroundColor(feedbackColor)

                    Text(feedbackText)
                        .font(.headline)
                        .foregroundColor(feedbackColor)

                    Spacer()
                }
                .padding()
                .background(feedbackColor.opacity(0.1))
                .cornerRadius(12)
            }

            // Cueing hierarchy — available on demand, before failing.
            if !cues.isEmpty {
                cuePanel
            }
        }
    }

    // MARK: Cue panel

    private var cuePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(cues.prefix(revealedCueCount).enumerated()), id: \.offset) { _, cue in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(cue.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        Text(cue.text)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    if cue.speakable {
                        Button {
                            SpeechService.shared.speak(spokenText(for: cue), languageCode: languageCode)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(10)
            }

            if revealedCueCount < cues.count {
                Button {
                    revealedCueCount += 1
                    let revealed = cues[revealedCueCount - 1]
                    if revealed.kind == .wholeWord {
                        SpeechService.shared.speak(spokenText(for: revealed), languageCode: languageCode)
                    }
                } label: {
                    HStack {
                        Image(systemName: "lightbulb")
                        Text(localizationManager.localize("need_hint"))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(12)
                }
            }
        }
    }

    private func spokenText(for cue: Cue) -> String {
        switch cue.kind {
        case .wholeWord: return exercise.correctAnswer ?? cue.text
        default: return cue.text
        }
    }

    // MARK: Feedback styling

    private var feedbackColor: Color {
        switch accuracy {
        case .correct: return .green
        case .approximate: return .blue
        case .incorrect: return .red
        }
    }

    private var feedbackIcon: String {
        switch accuracy {
        case .correct: return "checkmark.circle.fill"
        case .approximate: return "checkmark.circle"
        case .incorrect: return "xmark.circle.fill"
        }
    }

    private var feedbackText: String {
        switch accuracy {
        case .correct: return localizationManager.localize("correct")
        case .approximate: return localizationManager.localize("almost")
        case .incorrect: return localizationManager.localize("incorrect")
        }
    }
}

// MARK: - Answer Option Button

struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let showResult: Bool
    let isCorrect: Bool
    let languageCode: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(text)
                .font(.body)
                .foregroundColor(textColor)

            Spacer()

            if showResult && isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if showResult && isSelected && !isCorrect {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }

            // Per-option read-aloud
            Button {
                SpeechService.shared.speak(text, languageCode: languageCode)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !showResult { action() }
        }
    }

    private var backgroundColor: Color {
        if showResult && isCorrect {
            return Color.green.opacity(0.1)
        } else if showResult && isSelected && !isCorrect {
            return Color.red.opacity(0.1)
        } else if isSelected {
            return Color.blue.opacity(0.1)
        }
        return Color.white
    }

    private var borderColor: Color {
        if showResult && isCorrect {
            return .green
        } else if showResult && isSelected && !isCorrect {
            return .red
        } else if isSelected {
            return .blue
        }
        return Color.gray.opacity(0.3)
    }

    private var textColor: Color {
        if showResult && isCorrect {
            return .green
        } else if showResult && isSelected && !isCorrect {
            return .red
        }
        return .primary
    }
}

// MARK: - Session Completion View

struct SessionCompletionView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode

    let session: TherapySession
    let results: [ExerciseAnswer]
    let totalTime: Int
    let cuesUsed: Int

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text(localizationManager.localize("session_complete"))
                .font(.title)
                .fontWeight(.bold)

            // Statistics
            VStack(spacing: 20) {
                StatRow(
                    title: localizationManager.localize("your_score"),
                    value: "\(Int(scorePercentage))%",
                    color: .blue
                )

                StatRow(
                    title: localizationManager.localize("correct_answers"),
                    value: "\(correctCount) / \(results.count)",
                    color: .green
                )

                StatRow(
                    title: localizationManager.localize("time_taken"),
                    value: formatTime(totalTime),
                    color: .orange
                )

                if cuesUsed > 0 {
                    StatRow(
                        title: localizationManager.localize("hints_used"),
                        value: "\(cuesUsed)",
                        color: .purple
                    )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text(localizationManager.localize("back_to_home"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .padding()
    }

    private var correctCount: Int {
        results.filter { $0.isCorrect }.count
    }

    private var scorePercentage: Double {
        guard !results.isEmpty else { return 0 }
        return (Double(correctCount) / Double(results.count)) * 100
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct ExerciseSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSession = TherapySession(
            id: "1",
            name: "Sample Session",
            description: "A sample therapy session",
            type: .wordNaming,
            difficulty: .beginner,
            exercises: [],
            estimatedDuration: 10,
            language: "en",
            imageURL: nil
        )

        ExerciseSessionView(session: sampleSession)
            .environmentObject(AuthenticationManager())
            .environmentObject(APIClient())
            .environmentObject(LocalizationManager())
    }
}

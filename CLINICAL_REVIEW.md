# Clinical Review — Aphasia Therapy iOS App

> **Disclaimer:** This review was prepared by an AI engineering assistant, **not a
> licensed speech-language pathologist (SLP)**. It is grounded in well-established
> aphasia-rehabilitation practice, but every clinical decision below (exercise
> content, scoring thresholds, cueing wording) should be validated by a qualified
> SLP before this app is used with real patients. This app should **supplement, not
> replace**, professional therapy.

## How this was assessed

The review is based on a full read of the source (models, services, views) — what
the app *actually does*, not what the marketing copy claims. Findings are mapped to
the specific file that needs to change, with a status:

- ✅ **Implemented** in this change set
- 🟡 **Partially addressed** (foundation added; content/clinical validation still needed)
- ⬜ **Recommended** (not yet implemented)

---

## Summary

The app's *structure* is reasonable — its categories (naming, comprehension,
repetition, reading, writing) map to genuine aphasia treatment domains, and
self-paced home practice with streaks supports adherence (an evidence-supported
adjunct to clinician-led therapy). However, several **core mechanics did not match
how aphasia is actually treated**, and the single biggest gap was that a "speech
therapy" app contained **no speech** at all.

| # | Finding | Severity | Status |
|---|---------|----------|--------|
| 1 | No speech: no text-to-speech, no audio, no voice capture | Critical | 🟡 TTS added; voice capture ⬜ |
| 2 | Multiple choice tests *recognition*, not word *retrieval* | High | 🟡 |
| 3 | Exact-string scoring rejects normal aphasic near-misses | High | ✅ |
| 4 | Cueing was backwards (hints only *after* failure) | High | ✅ |
| 5 | Typed-text answers gate out users with agraphia/hemiparesis | High | 🟡 (TTS + cues reduce reliance; speech ⬜) |
| 6 | Mandatory account/login is an access barrier | High | ✅ (no-login practice mode) |
| 7 | "Comprehension"/"Reading" conflated; no auditory comprehension | Medium | 🟡 (TTS enables it; content ⬜) |
| 8 | No personalization to aphasia type/severity; no adaptivity | Medium | ⬜ |
| 9 | Forced light mode; low contrast; claims unmet | Medium | ⬜ |
| 10 | Dead settings toggles (haptics/sound not wired) | Low | ⬜ |
| 11 | Risk of machine-translating clinical stimuli | Medium | ⬜ (UI-only translation documented) |

---

## Detailed findings

### 1. A "speech therapy" app with no speech — Critical
**Files:** `Services/SpeechService.swift` (new), `Views/ExerciseSessionView.swift`
There was no microphone, recording, speech recognition, or text-to-speech anywhere;
the `voiceResponse` / `audioURL` model fields were unused, and a "voice" exercise
silently fell back to a text field.
- ✅ **Added `SpeechService`** (AVSpeechSynthesizer) with read-aloud of prompts and
  every answer option, a slightly reduced speech rate, and per-language voices.
- ⬜ **Still needed:** voice capture for naming/repetition (record + self-compare, or
  on-device `SFSpeechRecognizer` with approximate scoring). This is the next biggest
  lever and requires `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription`.

### 2. Multiple choice tests recognition, not retrieval — High
**Files:** `Models/TherapySession.swift`, `Views/ExerciseSessionView.swift`
Anomia (word-finding) is the most common aphasia symptom, and naming is a *production*
task. Choosing the right word among four options trains recognition, which is usually
more preserved, so progress can look good without training the impaired skill.
- 🟡 **Foundation:** fill-in (typed/spoken) items now get cueing + approximate scoring,
  making open production viable. Reserve multiple choice for comprehension/matching.
- ⬜ **Still needed:** picture-naming items with spoken responses; author content that
  distinguishes naming (produce) from comprehension (recognize).

### 3. Exact-string scoring — High
**File:** `Services/TherapyEngine.swift` (new), `Views/ExerciseSessionView.swift`
`checkAnswer` used `selectedAnswer == correctAnswer`. Aphasic responses include
phonemic paraphasias ("cay"→"cake"), self-corrections, and spelling slips (agraphia).
- ✅ **Added `AnswerEvaluator`**: normalizes case/diacritics/punctuation, credits
  self-corrections ("it's a cake" → "cake"), and accepts small edit-distance near-misses
  as **"Almost!"** (credited). Three-state feedback (Correct / Almost / Incorrect) replaces
  the binary right/wrong.
- 🟡 **Validate:** the 25%-of-length edit-distance tolerance is an engineering default;
  an SLP should confirm it per task type.

### 4. Cueing hierarchy — High
**File:** `Services/TherapyEngine.swift` (new), `Views/ExerciseSessionView.swift`
Hints previously appeared only *after* a wrong answer. Evidence-based naming therapy
uses graduated cues to *elicit* the word.
- ✅ **Added `CueGenerator`** producing an ordered hierarchy: **semantic → first sound
  → number of beats (syllables) → partial spelling → whole word (modelled aloud)**.
  A "Need a hint?" button steps through it *before* answering; an additional cue is
  auto-revealed after an error. Cues are spoken via TTS. Hints used per session are tracked.
- 🟡 **Validate:** the semantic cue uses author-provided `hints`; wording should be
  reviewed. Mirrors Semantic Feature Analysis (SFA) / Phonological Components Analysis (PCA).

### 5. Typed-text answers — High
**File:** `Views/ExerciseSessionView.swift`
Writing is commonly impaired and hemiparesis often affects the dominant hand.
- 🟡 Read-aloud + cueing + approximate scoring reduce the penalty for imperfect typing.
- ⬜ **Still needed:** spoken responses as a first-class input so typing is optional.

### 6. Mandatory login — High
**Files:** `Services/AuthenticationManager.swift`, `Views/ContentView.swift`,
`Views/AuthenticationView.swift`, `Services/LocalContent.swift` (new)
An email/password gate is a serious barrier for users with writing/memory deficits.
- ✅ **Added a no-login "Practice without an account" mode**: a guest can immediately
  practice using built-in `SampleContent`, with progress stored locally
  (`LocalProgressStore`) and surfaced on Home/Progress. The app also falls back to this
  content when the backend is unreachable, so screens are never a dead spinner.
- ⬜ **Still needed:** caregiver-assisted / passwordless onboarding for the account path.

### 7. Comprehension vs. reading; auditory comprehension — Medium
**Files:** content (backend / `Services/LocalContent.swift`)
Without audio, "comprehension" was reading-only.
- 🟡 TTS now makes auditory comprehension possible (hear a prompt, choose/point).
- ⬜ **Still needed:** items explicitly designed for *auditory* comprehension.

### 8. No personalization / adaptivity — Medium
**Files:** `Models/`, a future `TherapyPlan` service
Aphasia is heterogeneous (Broca's, Wernicke's, anomic, conduction, global, PPA…).
Static difficulty labels and fixed item sets don't adapt.
- ⬜ **Recommended:** a brief baseline, deficit-aware item selection, adaptive difficulty,
  and spaced repetition that re-surfaces missed items (massed practice improves outcomes).

### 9. Visual accessibility — Medium
**Files:** `AphasiaTherapyApp.swift` (`.preferredColorScheme(.light)`), views using
`Color.white` cards
Light mode is forced and contrast is low, despite README claims of "high contrast ready".
- ⬜ **Recommended:** respect system appearance, add a high-contrast / large-text theme,
  more white space, one idea per screen (Aphasia Institute / Stroke Association guidance).

### 10. Dead settings toggles — Low
**File:** `Views/ProfileView.swift`
"Sound effects" and "Haptic feedback" toggles are stored but never gate behavior
(haptics fire regardless; there is no sound).
- ⬜ **Recommended:** wire them to `HapticManager`/`SpeechService`, or remove them.

### 11. Translation of clinical content — Medium
**Files:** `Services/TranslationService.swift`, `Services/LocalizationManager.swift`
UI-label translation via LLM is fine. Therapy *stimuli* (rhyme, first-sound, syllable
tasks; word frequency; picturability) are language-specific and must not be machine
translated. Current exercise content is fetched per-language from the backend (correct),
but the "AI translation for 36+ languages" positioning should never be applied to stimuli
without per-language clinician review.

---

## What this change set implemented (Part B)

1. **Read-aloud (TTS)** — `SpeechService` + Listen buttons on prompts and options.
2. **Approximate scoring** — `AnswerEvaluator` + 3-state Correct/Almost/Incorrect feedback.
3. **Cueing hierarchy** — `CueGenerator` + on-demand "Need a hint?" that elicits before failure.
4. **No-login practice mode** — guest flow + `SampleContent` + `LocalProgressStore`, plus
   offline fallback for logged-in users.

## Highest-value next steps (not yet implemented)

1. **Voice capture** for naming/repetition (mic + optional on-device recognition).
2. **Picture-naming production** items (vs. recognition).
3. **Baseline + adaptive difficulty + spaced repetition.**
4. **Accessibility theme**: high-contrast/dark, large text, reduced time pressure.
5. **SLP-authored, per-language content** and confirmation of scoring/cue wording.

## References (frameworks this aligns with)
- Aphasia Institute — Supported Conversation for Adults with Aphasia (SCA™); aphasia-friendly formatting.
- Stroke Association / Aphasia-friendly communication guidelines.
- Naming treatments: Semantic Feature Analysis (SFA), Phonological Components Analysis (PCA), cueing hierarchies.
- Dosage: intensive / constraint-induced aphasia therapy literature.

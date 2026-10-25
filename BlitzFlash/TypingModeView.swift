import SwiftUI

struct TypingModeView: View {
    var words: [VocabularyWord]
    var learningLanguage: LearningLanguage = .english

    @Environment(MonetizationStore.self) private var monetization
    @Environment(\.blitzLayout) private var layout

    @State private var picker = WordPicker()
    @State private var currentWord: VocabularyWord?
    @State private var answer = ""
    @State private var correct = 0
    @State private var wrong = 0
    @State private var secondsLeft = Self.roundSeconds
    @State private var hasStarted = false
    @State private var isFinished = false
    @State private var feedback: TypingFeedback?
    @State private var finishedAt = Date()
    @State private var delay = Delay()
    @FocusState private var isFieldFocused: Bool

    private static let roundSeconds = 60

    private var score: Int { correct * 5 - wrong * 3 }

    var body: some View {
        VStack(spacing: layout.isShort ? 12 : 18) {
            if !layout.isSplit && !layout.hasSideRail {
                statsRow
            }

            if isFinished {
                // İç ekranda sonuç bir bölmede, sayaçlar diğerinde; kart çizgiye denk gelmez.
                AdaptiveSplit {
                    ResultCard(
                        title: "Yazarak Tahmin Sonucu",
                        score: score,
                        detail: "\(correct) doğru, \(wrong) yanlış",
                        finishedAt: finishedAt,
                        onReplay: restart
                    )
                    Spacer(minLength: 0)
                } secondary: {
                    if layout.isSplit { statsRow }
                    Spacer(minLength: 0)
                }
            } else {
                AdaptiveSplit {
                    wordCard
                    if layout.isTall {
                        // Dikte klavye alt yarıyı kaplar: yazı alanı kartla birlikte üstte.
                        answerField
                        feedbackSlot
                    }
                    if layout.isSplit { Spacer(minLength: 0) }
                } secondary: {
                    if layout.isSplit {
                        statsRow
                        timerBar
                    }
                    if layout.isTall {
                        checkButton
                    } else {
                        answerField
                        checkButton
                        feedbackSlot
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(layout.isShort ? 16 : 20)
        .blitzScreen()
        .navigationTitle(BlitzMode.typing.title)
        .navigationBarTitleDisplayMode(.inline)
        .sideRail(layout) { statsRow }
        .sensoryFeedback(.success, trigger: correct)
        .sensoryFeedback(.error, trigger: wrong)
        .onAppear {
            if currentWord == nil { currentWord = picker.next(from: words) }
        }
        .onDisappear { delay.cancel() }
        .task(id: hasStarted) {
            guard hasStarted else { return }
            while secondsLeft > 0, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                secondsLeft -= 1
            }
            if secondsLeft == 0 { finish() }
        }
    }

    private var statsRow: some View {
        StatGroup {
            StatPill(title: "Puan", value: score, color: BlitzTheme.primary)
            StatPill(title: "Doğru", value: correct, color: BlitzTheme.success)
            StatPill(title: "Yanlış", value: wrong, color: BlitzTheme.danger)
            StatPill(title: "Süre", value: secondsLeft, color: secondsLeft <= 10 ? BlitzTheme.danger : BlitzTheme.accent)
        }
    }

    private var timerBar: some View {
        ProgressView(value: Double(secondsLeft), total: Double(Self.roundSeconds))
            .tint(secondsLeft <= 10 ? BlitzTheme.danger : BlitzTheme.accent)
            .animation(.linear(duration: 1), value: secondsLeft)
    }

    private var wordCard: some View {
        let word = currentWord ?? words[0]
        return BlitzCard {
            VStack(spacing: 14) {
                Text(learningLanguage.nativeTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BlitzTheme.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(BlitzTheme.primary.opacity(0.12), in: .capsule)

                Text(word.targetTerm(for: learningLanguage))
                    .font(.system(size: layout.isShort ? 32 : 40, weight: .bold, design: .rounded))
                    .foregroundStyle(BlitzTheme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.opacity)

                if let sentence = word.targetSentence(for: learningLanguage) {
                    Text(sentence)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.muted)
                }
            }
            .frame(maxWidth: .infinity, minHeight: layout.isShort || layout.isTall ? 150 : 220)
        }
    }

    private var answerField: some View {
        TextField("Türkçe çevirisini yaz...", text: $answer)
            .blitzAnswerField()
            .focused($isFieldFocused)
            .onSubmit(checkAnswer)
            .disabled(feedback != nil)
    }

    private var checkButton: some View {
        Button(action: checkAnswer) {
            BlitzButtonLabel(title: "Kontrol Et", icon: "arrow.right")
        }
        .blitzButton()
        .disabled(feedback != nil || answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @ViewBuilder
    private var feedbackSlot: some View {
        if let feedback {
            feedbackPanel(feedback)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func checkAnswer() {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isFinished, feedback == nil, !trimmed.isEmpty, let word = currentWord else { return }
        guard monetization.spend() else { return }
        hasStarted = true

        let isCorrect = word.matches(trimmed)
        if isCorrect { correct += 1 } else { wrong += 1 }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            feedback = TypingFeedback(isCorrect: isCorrect, target: word.targetTerm(for: learningLanguage), turkish: word.turkish)
        }
        answer = ""

        delay.run(after: isCorrect ? 1.1 : 2.35) {
            withAnimation(.easeOut(duration: 0.18)) { feedback = nil }
            currentWord = picker.next(from: words)
            isFieldFocused = true
        }
    }

    private func feedbackPanel(_ feedback: TypingFeedback) -> some View {
        let tint = feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger
        return HStack(spacing: 12) {
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.isCorrect ? "Doğru cevap" : "Doğru çeviri")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tint)

                Text("\(feedback.target) = \(feedback.turkish)")
                    .font(.headline)
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
            }

            Spacer()
        }
        .padding(14)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 14))
    }

    private func finish() {
        delay.cancel()
        finishedAt = Date()
        isFinished = true
        feedback = nil
    }

    private func restart() {
        picker = WordPicker()
        currentWord = picker.next(from: words)
        answer = ""
        correct = 0
        wrong = 0
        secondsLeft = Self.roundSeconds
        hasStarted = false
        isFinished = false
        feedback = nil
    }
}

private struct TypingFeedback {
    let isCorrect: Bool
    let target: String
    let turkish: String
}

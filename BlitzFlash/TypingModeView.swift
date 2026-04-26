import SwiftUI
import Combine

struct TypingModeView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var answer = ""
    @State private var correct = 0
    @State private var wrong = 0
    @State private var score = 0
    @State private var secondsLeft = 60
    @State private var hasStarted = false
    @State private var isFinished = false
    @State private var feedback: TypingFeedback?
    @State private var isResolvingAnswer = false
    @State private var finishedAt = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentWord: VocabularyWord {
        words[min(currentIndex, words.count - 1)]
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Puan", value: score, color: BlitzTheme.primary)
                StatPill(title: "Doğru", value: correct, color: BlitzTheme.success)
                StatPill(title: "Yanlış", value: wrong, color: BlitzTheme.danger)
                StatPill(title: "Süre", value: secondsLeft, color: secondsLeft <= 10 ? BlitzTheme.danger : BlitzTheme.accent)
            }

            if isFinished {
                resultPanel
            } else {
                BlitzCard(glow: BlitzTheme.secondary) {
                    VStack(spacing: 14) {
                        Text("English")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(BlitzTheme.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(BlitzTheme.primary.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        Text(currentWord.english)
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)
                            .shadow(color: BlitzTheme.primary.opacity(0.24), radius: 18, x: 0, y: 0)

                        Text(currentWord.englishSentence)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 220)
                }

                TextField("Çeviriyi yaz...", text: $answer)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit(checkAnswer)
                    .padding(14)
                    .foregroundStyle(BlitzTheme.ink)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(BlitzTheme.surface)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(BlitzTheme.primary.opacity(0.2), lineWidth: 1)
                            }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .disabled(isResolvingAnswer)

                Button(action: checkAnswer) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(BlitzTheme.accent)
                                .frame(width: 34, height: 34)

                            Image(systemName: "bolt.fill")
                                .font(.headline.weight(.black))
                                .foregroundStyle(BlitzTheme.background)
                        }

                        Text("Kontrol Et")
                            .font(.headline.weight(.black))

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3.weight(.bold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BlitzProminentButton(tint: answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? BlitzTheme.dim : BlitzTheme.secondary))
                    .disabled(isResolvingAnswer || answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if let feedback {
                    feedbackPanel(feedback)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            Spacer()
        }
        .padding(20)
        .blitzScreen()
        .navigationTitle("Yazarak Tahmin")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard hasStarted, !isFinished else { return }
            secondsLeft = max(secondsLeft - 1, 0)
            if secondsLeft <= 0 {
                finishGame()
            }
        }
    }

    private var resultPanel: some View {
        BlitzCard(glow: BlitzTheme.accent) {
            VStack(spacing: 14) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(BlitzTheme.accent)

                Text("Yazarak Tahmin Sonucu")
                    .font(.title2.weight(.black))
                    .foregroundStyle(BlitzTheme.ink)

                Text("\(formattedDate(finishedAt)) • \(formattedTime(finishedAt))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BlitzTheme.muted)

                Text("\(score) puan")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(score >= 0 ? BlitzTheme.success : BlitzTheme.danger)
                    .shadow(color: (score >= 0 ? BlitzTheme.success : BlitzTheme.danger).opacity(0.24), radius: 18, x: 0, y: 0)

                Text("\(correct) doğru, \(wrong) yanlış")
                    .font(.body)
                    .foregroundStyle(BlitzTheme.muted)

                Button("Tekrar Oyna") {
                    currentIndex = 0
                    answer = ""
                    correct = 0
                    wrong = 0
                    score = 0
                    secondsLeft = 60
                    hasStarted = false
                    isFinished = false
                    feedback = nil
                    isResolvingAnswer = false
                    finishedAt = Date()
                }
                .font(.headline)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .buttonStyle(BlitzProminentButton(tint: BlitzTheme.accent, darkText: true))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func checkAnswer() {
        guard !isFinished, !isResolvingAnswer else { return }
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAnswer.isEmpty else { return }
        hasStarted = true

        let answeredWord = currentWord
        let isCorrect = answeredWord.matches(trimmedAnswer)
        isResolvingAnswer = true

        if isCorrect {
            correct += 1
            score += 5
        } else {
            wrong += 1
            score -= 3
        }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            feedback = TypingFeedback(isCorrect: isCorrect, english: answeredWord.english, turkish: answeredWord.turkish)
        }

        answer = ""

        let delay = isCorrect ? 1.1 : 2.35
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isResolvingAnswer else { return }
            withAnimation(.easeOut(duration: 0.18)) {
                feedback = nil
            }
            currentIndex = (currentIndex + 1) % words.count
            isResolvingAnswer = false
        }
    }

    private func feedbackPanel(_ feedback: TypingFeedback) -> some View {
        HStack(spacing: 12) {
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger)

            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.isCorrect ? "Doğru cevap" : "Doğru çeviri")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger)

                Text("\(feedback.english) = \(feedback.turkish)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(BlitzTheme.surfaceLight.opacity(0.9))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke((feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger).opacity(0.38), lineWidth: 1)
                }
        )
    }

    private func finishGame() {
        finishedAt = Date()
        isFinished = true
        isResolvingAnswer = false
        feedback = nil
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle
                .dateTime
                .locale(Locale(identifier: "tr_TR"))
                .day()
                .month(.wide)
                .year()
        )
    }

    private func formattedTime(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle
                .dateTime
                .locale(Locale(identifier: "tr_TR"))
                .hour()
                .minute()
        )
    }
}

private struct TypingFeedback {
    let isCorrect: Bool
    let english: String
    let turkish: String
}

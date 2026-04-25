import SwiftUI
import Combine

struct TypingModeView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var answer = ""
    @State private var correct = 0
    @State private var wrong = 0
    @State private var secondsLeft = 60
    @State private var hasStarted = false
    @State private var isFinished = false
    @State private var feedback: String?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentWord: VocabularyWord {
        words[min(currentIndex, words.count - 1)]
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
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

                TextField("Ceviriyi yaz...", text: $answer)
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

                Button("Kontrol Et", action: checkAnswer)
                    .font(.headline)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(BlitzProminentButton(tint: BlitzTheme.secondary))
                    .frame(maxWidth: .infinity)

                if let feedback {
                    Text(feedback)
                        .font(.subheadline.weight(.semibold))
                    .foregroundStyle(feedback.hasPrefix("Doğru") ? BlitzTheme.success : BlitzTheme.danger)
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
            secondsLeft -= 1
            if secondsLeft <= 0 {
                isFinished = true
            }
        }
    }

    private var resultPanel: some View {
        BlitzCard(glow: BlitzTheme.accent) {
            VStack(spacing: 14) {
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(BlitzTheme.warm)

                Text("Skorun \(correct)")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)

                Text("\(correct) dogru, \(wrong) yanlis")
                    .font(.body)
                    .foregroundStyle(BlitzTheme.muted)

                Button("Tekrar Oyna") {
                    currentIndex = 0
                    answer = ""
                    correct = 0
                    wrong = 0
                    secondsLeft = 60
                    hasStarted = false
                    isFinished = false
                    feedback = nil
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
        guard !isFinished else { return }
        hasStarted = true

        if currentWord.matches(answer) {
            correct += 1
            feedback = "Doğru: \(currentWord.turkish)"
        } else {
            wrong += 1
            feedback = "Yanlış: \(currentWord.turkish)"
        }

        answer = ""
        currentIndex = (currentIndex + 1) % words.count
    }
}

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
                StatPill(title: "Dogru", value: correct, color: BlitzTheme.secondary)
                StatPill(title: "Yanlis", value: wrong, color: BlitzTheme.warm)
                StatPill(title: "Sure", value: secondsLeft, color: BlitzTheme.primary)
            }

            if isFinished {
                resultPanel
            } else {
                BlitzCard {
                    VStack(spacing: 14) {
                        Text("English")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(BlitzTheme.primary)

                        Text(currentWord.english)
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(BlitzTheme.ink)

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
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button("Kontrol Et", action: checkAnswer)
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                if let feedback {
                    Text(feedback)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(feedback.hasPrefix("Dogru") ? BlitzTheme.secondary : BlitzTheme.warm)
                }
            }

            Spacer()
        }
        .padding(20)
        .background(BlitzTheme.surface)
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
        BlitzCard {
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
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func checkAnswer() {
        guard !isFinished else { return }
        hasStarted = true

        if currentWord.matches(answer) {
            correct += 1
            feedback = "Dogru: \(currentWord.turkish)"
        } else {
            wrong += 1
            feedback = "Yanlis: \(currentWord.turkish)"
        }

        answer = ""
        currentIndex = (currentIndex + 1) % words.count
    }
}

import SwiftUI

struct SentenceModeView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var correct = 0
    @State private var wrong = 0

    private var currentWord: VocabularyWord {
        words[min(currentIndex, words.count - 1)]
    }

    private var options: [String] {
        var values = [currentWord.english]
        values.append(contentsOf: words.shuffled().prefix(3).map(\.english))
        return Array(Set(values)).shuffled().prefix(4).map { $0 }
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Dogru", value: correct, color: BlitzTheme.success)
                StatPill(title: "Yanlis", value: wrong, color: BlitzTheme.danger)
            }

            BlitzCard(glow: BlitzTheme.success) {
                VStack(spacing: 14) {
                    Text(sentenceWithBlank)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.ink)
                        .shadow(color: BlitzTheme.success.opacity(0.18), radius: 16, x: 0, y: 0)

                    if selectedAnswer != nil {
                        Text(currentWord.turkishSentence)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 220)
            }

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        choose(option)
                    } label: {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedAnswer == option {
                                Image(systemName: option == currentWord.english ? "checkmark.circle.fill" : "xmark.circle.fill")
                            }
                        }
                        .font(.headline)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .background(optionBackground(option))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(optionBorder(option), lineWidth: 1)
                    }
                }
            }

            Button("Sonraki Cumle") {
                selectedAnswer = nil
                currentIndex = (currentIndex + 1) % words.count
            }
            .font(.headline)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .buttonStyle(BlitzProminentButton(tint: BlitzTheme.primary))
            .disabled(selectedAnswer == nil)

            Spacer()
        }
        .padding(20)
        .blitzScreen()
        .navigationTitle("Cumle Tamamla")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sentenceWithBlank: String {
        currentWord.englishSentence.replacingOccurrences(
            of: currentWord.english,
            with: "_____",
            options: [.caseInsensitive]
        )
    }

    private func choose(_ option: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = option
        if option == currentWord.english {
            correct += 1
        } else {
            wrong += 1
        }
    }

    private func optionBackground(_ option: String) -> Color {
        guard let selectedAnswer else { return BlitzTheme.surface }
        if option == currentWord.english { return BlitzTheme.success.opacity(0.2) }
        if option == selectedAnswer { return BlitzTheme.danger.opacity(0.22) }
        return BlitzTheme.surface
    }

    private func optionBorder(_ option: String) -> Color {
        guard let selectedAnswer else { return BlitzTheme.primary.opacity(0.1) }
        if option == currentWord.english { return BlitzTheme.success.opacity(0.45) }
        if option == selectedAnswer { return BlitzTheme.danger.opacity(0.45) }
        return BlitzTheme.primary.opacity(0.08)
    }
}

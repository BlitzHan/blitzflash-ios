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
                StatPill(title: "Dogru", value: correct, color: BlitzTheme.secondary)
                StatPill(title: "Yanlis", value: wrong, color: BlitzTheme.warm)
            }

            BlitzCard {
                VStack(spacing: 14) {
                    Text(sentenceWithBlank)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.ink)

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
                }
            }

            Button("Sonraki Cumle") {
                selectedAnswer = nil
                currentIndex = (currentIndex + 1) % words.count
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedAnswer == nil)

            Spacer()
        }
        .padding(20)
        .background(BlitzTheme.surface)
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
        guard let selectedAnswer else { return Color(uiColor: .systemBackground) }
        if option == currentWord.english { return BlitzTheme.secondary.opacity(0.18) }
        if option == selectedAnswer { return BlitzTheme.warm.opacity(0.2) }
        return Color(uiColor: .systemBackground)
    }
}

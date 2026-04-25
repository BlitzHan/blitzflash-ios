import SwiftUI

struct SentenceModeView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var correct = 0
    @State private var wrong = 0
    @State private var currentOptions: [String] = []

    private var currentWord: VocabularyWord {
        words[min(currentIndex, words.count - 1)]
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Doğru", value: correct, color: BlitzTheme.success)
                StatPill(title: "Yanlış", value: wrong, color: BlitzTheme.danger)
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
                ForEach(currentOptions, id: \.self) { option in
                    Button {
                        choose(option)
                    } label: {
                        HStack(spacing: 12) {
                            Text(option)
                                .foregroundStyle(optionTextColor(option))
                                .lineLimit(2)
                                .minimumScaleFactor(0.86)

                            Spacer()

                            if selectedAnswer == option {
                                Image(systemName: option == currentWord.english ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(option == currentWord.english ? BlitzTheme.success : BlitzTheme.danger)
                            } else if selectedAnswer != nil, option == currentWord.english {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(BlitzTheme.success)
                            }
                        }
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(optionBackground(option))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(optionBorder(option), lineWidth: 1)
                    }
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(optionAccent(option))
                            .frame(width: 4)
                    }
                    .disabled(selectedAnswer != nil)
                }
            }

            Button {
                goToNextSentence()
            } label: {
                Label("Sonraki Cümle", systemImage: "bolt.fill")
                    .font(.headline)
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BlitzProminentButton(tint: selectedAnswer == nil ? BlitzTheme.dim : BlitzTheme.accent, darkText: selectedAnswer != nil))
            .disabled(selectedAnswer == nil)

            Spacer()
        }
        .padding(20)
        .blitzScreen()
        .navigationTitle("Cümle Tamamla")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: prepareOptions)
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
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            selectedAnswer = option
        }
        if option == currentWord.english {
            correct += 1
        } else {
            wrong += 1
        }
    }

    private func goToNextSentence() {
        selectedAnswer = nil
        currentIndex = (currentIndex + 1) % words.count
        prepareOptions()
    }

    private func prepareOptions() {
        var values = [currentWord.english]
        let distractors = words
            .filter { $0.id != currentWord.id }
            .shuffled()
            .prefix(3)
            .map(\.english)
        values.append(contentsOf: distractors)
        currentOptions = Array(Set(values)).shuffled()
    }

    private func optionBackground(_ option: String) -> AnyShapeStyle {
        guard selectedAnswer != nil else { return AnyShapeStyle(BlitzTheme.surface) }
        if option == currentWord.english {
            return AnyShapeStyle(LinearGradient(
                colors: [BlitzTheme.success.opacity(0.28), BlitzTheme.surfaceLight],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
        if option == selectedAnswer {
            return AnyShapeStyle(LinearGradient(
                colors: [BlitzTheme.danger.opacity(0.3), BlitzTheme.surfaceLight],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
        return AnyShapeStyle(BlitzTheme.surface)
    }

    private func optionBorder(_ option: String) -> Color {
        guard let selectedAnswer else { return BlitzTheme.primary.opacity(0.1) }
        if option == currentWord.english { return BlitzTheme.success.opacity(0.7) }
        if option == selectedAnswer { return BlitzTheme.danger.opacity(0.7) }
        return BlitzTheme.primary.opacity(0.08)
    }

    private func optionAccent(_ option: String) -> Color {
        guard let selectedAnswer else { return BlitzTheme.primary.opacity(0.42) }
        if option == currentWord.english { return BlitzTheme.success }
        if option == selectedAnswer { return BlitzTheme.danger }
        return BlitzTheme.dim
    }

    private func optionTextColor(_ option: String) -> Color {
        guard selectedAnswer != nil else { return BlitzTheme.ink }
        if option == currentWord.english || option == selectedAnswer { return BlitzTheme.ink }
        return BlitzTheme.muted
    }
}

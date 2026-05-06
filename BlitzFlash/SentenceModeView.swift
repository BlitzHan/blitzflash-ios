import SwiftUI

struct SentenceModeView: View {
    var words: [VocabularyWord]
    var learningLanguage: LearningLanguage = .english

    @State private var currentWord: VocabularyWord?
    @State private var recentWordIDs: [UUID] = []
    @State private var selectedAnswerID: UUID?
    @State private var correct = 0
    @State private var wrong = 0
    @State private var currentOptions: [VocabularyWord] = []
    @State private var isAutoAdvancing = false

    private var displayedWord: VocabularyWord {
        currentWord ?? words.randomElement() ?? words[0]
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Doğru", value: correct, color: BlitzTheme.success)
                StatPill(title: "Yanlış", value: wrong, color: BlitzTheme.danger)
            }

            AdSlotView(placement: "Cümle Tamamla")

            BlitzCard(glow: BlitzTheme.success) {
                VStack(spacing: 14) {
                    Text(sentenceWithBlank)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.ink)
                        .shadow(color: BlitzTheme.success.opacity(0.18), radius: 16, x: 0, y: 0)

                    if selectedAnswerID != nil {
                        Text(displayedWord.turkishSentence)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 220)
            }

            VStack(spacing: 10) {
                ForEach(currentOptions, id: \.id) { option in
                    let optionText = option.targetTerm(for: learningLanguage)

                    Button {
                        choose(option)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(optionText)
                                    .foregroundStyle(optionTextColor(option))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.86)

                                if selectedAnswerID != nil {
                                    Text(option.turkish)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(BlitzTheme.muted)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.84)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }

                            Spacer()

                            if selectedAnswerID == option.id {
                                Image(systemName: option.id == displayedWord.id ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(option.id == displayedWord.id ? BlitzTheme.success : BlitzTheme.danger)
                            } else if selectedAnswerID != nil, option.id == displayedWord.id {
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
                    .disabled(selectedAnswerID != nil)
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
            .buttonStyle(BlitzProminentButton(tint: selectedAnswerID == nil ? BlitzTheme.dim : BlitzTheme.accent, darkText: selectedAnswerID != nil))
            .disabled(selectedAnswerID == nil || isAutoAdvancing)

            Spacer()
        }
        .padding(20)
        .blitzScreen()
        .navigationTitle("Cümle Tamamla")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prepareSentenceIfNeeded()
        }
    }

    private var sentenceWithBlank: String {
        let sentence = displayedWord.targetSentence(for: learningLanguage)
        let answer = correctAnswer
        let blanked = sentence.replacingOccurrences(
            of: answer,
            with: "_____",
            options: [.caseInsensitive]
        )
        return blanked == sentence ? "\(answer) - _____" : blanked
    }

    private var correctAnswer: String {
        displayedWord.targetTerm(for: learningLanguage)
    }

    private func choose(_ option: VocabularyWord) {
        guard selectedAnswerID == nil else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            selectedAnswerID = option.id
        }
        if option.id == displayedWord.id {
            correct += 1
        } else {
            wrong += 1
        }
        scheduleNextSentence()
    }

    private func goToNextSentence() {
        isAutoAdvancing = false
        selectedAnswerID = nil
        selectRandomSentence()
        prepareOptions()
    }

    private func prepareOptions() {
        let word = displayedWord
        var values = [word]
        let distractors = words
            .filter { $0.id != word.id }
            .shuffled()
            .prefix(3)
        values.append(contentsOf: distractors)
        currentOptions = values.shuffled()
    }

    private func prepareSentenceIfNeeded() {
        guard currentWord == nil else { return }
        selectRandomSentence()
        prepareOptions()
    }

    private func selectRandomSentence() {
        guard !words.isEmpty else { return }
        let pool = words.filter { !recentWordIDs.contains($0.id) }
        let nextWord = (pool.isEmpty ? words : pool).randomElement()
        currentWord = nextWord

        if let nextWord {
            recentWordIDs.append(nextWord.id)
            if recentWordIDs.count > 40 {
                recentWordIDs.removeFirst(recentWordIDs.count - 40)
            }
        }
    }

    private func scheduleNextSentence() {
        isAutoAdvancing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            guard isAutoAdvancing, selectedAnswerID != nil else { return }
            withAnimation(.easeInOut(duration: 0.22)) {
                goToNextSentence()
            }
        }
    }

    private func optionBackground(_ option: VocabularyWord) -> AnyShapeStyle {
        guard selectedAnswerID != nil else { return AnyShapeStyle(BlitzTheme.surface) }
        if option.id == displayedWord.id {
            return AnyShapeStyle(LinearGradient(
                colors: [BlitzTheme.success.opacity(0.28), BlitzTheme.surfaceLight],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
        if option.id == selectedAnswerID {
            return AnyShapeStyle(LinearGradient(
                colors: [BlitzTheme.danger.opacity(0.3), BlitzTheme.surfaceLight],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
        return AnyShapeStyle(BlitzTheme.surface)
    }

    private func optionBorder(_ option: VocabularyWord) -> Color {
        guard selectedAnswerID != nil else { return BlitzTheme.primary.opacity(0.1) }
        if option.id == displayedWord.id { return BlitzTheme.success.opacity(0.7) }
        if option.id == selectedAnswerID { return BlitzTheme.danger.opacity(0.7) }
        return BlitzTheme.primary.opacity(0.08)
    }

    private func optionAccent(_ option: VocabularyWord) -> Color {
        guard selectedAnswerID != nil else { return BlitzTheme.primary.opacity(0.42) }
        if option.id == displayedWord.id { return BlitzTheme.success }
        if option.id == selectedAnswerID { return BlitzTheme.danger }
        return BlitzTheme.dim
    }

    private func optionTextColor(_ option: VocabularyWord) -> Color {
        guard selectedAnswerID != nil else { return BlitzTheme.ink }
        if option.id == displayedWord.id || option.id == selectedAnswerID { return BlitzTheme.ink }
        return BlitzTheme.muted
    }
}

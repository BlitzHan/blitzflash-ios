import SwiftUI

struct SentenceModeView: View {
    var words: [VocabularyWord]
    var learningLanguage: LearningLanguage = .english

    @Environment(MonetizationStore.self) private var monetization
    @Environment(\.blitzLayout) private var layout

    @State private var picker = WordPicker()
    @State private var currentWord: VocabularyWord?
    @State private var options: [VocabularyWord] = []
    @State private var selectedID: UUID?
    @State private var correct = 0
    @State private var wrong = 0
    @State private var delay = Delay()

    private var word: VocabularyWord { currentWord ?? words[0] }
    private var isAnswered: Bool { selectedID != nil }

    var body: some View {
        VStack(spacing: layout.isShort ? 12 : 18) {
            HStack {
                StatPill(title: "Doğru", value: correct, color: BlitzTheme.success)
                StatPill(title: "Yanlış", value: wrong, color: BlitzTheme.danger)
            }

            AdaptiveSplit {
                questionCard
                if layout.isWide { Spacer(minLength: 0) }
            } secondary: {
                VStack(spacing: 10) {
                    ForEach(options) { optionButton($0) }
                }

                Button(action: next) {
                    BlitzButtonLabel(title: "Sonraki Cümle", icon: "bolt.fill")
                }
                .blitzButton()
                .disabled(!isAnswered)

                Spacer(minLength: 0)
            }
        }
        .padding(layout.isShort ? 16 : 20)
        .blitzScreen()
        .navigationTitle(BlitzMode.sentence.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: correct)
        .sensoryFeedback(.error, trigger: wrong)
        .onAppear {
            if currentWord == nil { next() }
        }
        .onDisappear { delay.cancel() }
    }

    private var questionCard: some View {
        BlitzCard {
            VStack(spacing: 14) {
                if let sentence = blankedSentence {
                    Text(sentence)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(BlitzTheme.ink)
                    if isAnswered {
                        Text(word.turkishSentence)
                            .font(.body)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                } else {
                    // Hedef dilde gerçek örnek cümle yoksa Türkçe cümleden karşılığı sor.
                    Text(word.turkishSentence)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(BlitzTheme.ink)
                    Text("«\(word.turkish)» için doğru \(learningLanguage.title) kelimeyi seç.")
                        .font(.subheadline)
                        .foregroundStyle(BlitzTheme.muted)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: layout.isShort ? 150 : 220)
        }
    }

    /// Cümledeki hedef kelimeyi tam kelime olarak boşluğa çevirir ("art" → "start" bozulmaz).
    /// Kelime cümlede birebir geçmiyorsa (çekimli hâl vb.) cevabı ele vermemek için `nil`.
    private var blankedSentence: String? {
        guard let sentence = word.targetSentence(for: learningLanguage) else { return nil }
        let term = NSRegularExpression.escapedPattern(for: word.targetTerm(for: learningLanguage))
        guard let range = sentence.range(of: "\\b\(term)\\b", options: [.regularExpression, .caseInsensitive]) else {
            return nil
        }
        return sentence.replacingCharacters(in: range, with: "_____")
    }

    private func optionButton(_ option: VocabularyWord) -> some View {
        let isCorrect = option.id == word.id
        let isSelected = option.id == selectedID
        let tint: Color? = !isAnswered ? nil : isCorrect ? BlitzTheme.success : isSelected ? BlitzTheme.danger : nil

        return Button {
            choose(option)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(option.targetTerm(for: learningLanguage))
                        .foregroundStyle(isAnswered && tint == nil ? BlitzTheme.muted : BlitzTheme.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)

                    if isAnswered {
                        Text(option.turkish)
                            .font(.subheadline)
                            .foregroundStyle(BlitzTheme.muted)
                            .lineLimit(2)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer()

                if let tint {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(tint)
                }
            }
            .font(.headline)
            .padding(.horizontal, 14)
            .padding(.vertical, layout.isShort ? 11 : 15)
            .frame(maxWidth: .infinity, minHeight: layout.isShort ? 48 : 56)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint?.opacity(0.12) ?? BlitzTheme.surface)
                .stroke(tint?.opacity(0.6) ?? .clear, lineWidth: 1.5)
        }
        .shadow(color: BlitzTheme.cardShadow, radius: 6, x: 0, y: 2)
        .disabled(isAnswered)
    }

    private func choose(_ option: VocabularyWord) {
        guard !isAnswered, monetization.spend() else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            selectedID = option.id
        }
        if option.id == word.id { correct += 1 } else { wrong += 1 }
        delay.run(after: 2.4) { withAnimation(.easeInOut(duration: 0.22)) { next() } }
    }

    private func next() {
        delay.cancel()
        selectedID = nil
        guard let word = picker.next(from: words) else { return }
        currentWord = word
        let distractors = words.lazy.filter { $0.id != word.id }.shuffled().prefix(3)
        options = ([word] + distractors).shuffled()
    }
}

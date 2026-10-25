import SwiftUI

struct WordHuntView: View {
    var words: [VocabularyWord]
    var learningLanguage: LearningLanguage = .english

    @Environment(MonetizationStore.self) private var monetization
    @Environment(\.blitzLayout) private var layout
    @AppStorage("wordHuntBestScore") private var bestScore = 0
    @AppStorage("wordHuntHasBestScore") private var hasBestScore = false

    @State private var selectedWord: VocabularyWord?
    @State private var answer = ""
    @State private var solved: Set<UUID> = []
    @State private var failed: Set<UUID> = []
    @State private var attempts: [UUID: Int] = [:]
    @State private var roundWords: [VocabularyWord] = []
    @State private var prompts: [UUID: WordHuntPrompt] = [:]
    @State private var score = 0
    @State private var feedback: Feedback?
    @State private var isFinished = false
    @State private var finishedAt = Date()
    @State private var isNewBest = false

    private static let roundSize = 15
    private static let maxAttempts = 3

    var body: some View {
        Group {
            if isFinished {
                resultView
            } else if layout.isWide {
                // Duo iç ekranı: solda ızgara, sağda cevap paneli; sayfa açılmaz.
                AdaptiveSplit {
                    ScrollView { grid }
                        .scrollIndicators(.hidden)
                } secondary: {
                    statsRow
                    if let selectedWord {
                        answerPanel(for: selectedWord)
                    } else {
                        placeholderPanel
                    }
                    Spacer(minLength: 0)
                    finishButton
                }
                .padding(20)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        statsRow
                        grid
                        finishButton
                    }
                    .padding(layout.isShort ? 16 : 20)
                }
                .scrollContentBackground(.hidden)
                .sheet(item: $selectedWord) { word in
                    ScrollView {
                        answerPanel(for: word).padding(20)
                    }
                    .blitzScreen()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .blitzScreen()
        .navigationTitle(BlitzMode.hunt.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: solved.count)
        .sensoryFeedback(.error, trigger: failed.count)
        .onAppear {
            if prompts.isEmpty { newRound() }
        }
    }

    private var statsRow: some View {
        HStack {
            StatPill(title: "Puan", value: score, color: BlitzTheme.primary)
            StatPill(title: "Bitti", value: solved.count + failed.count, color: BlitzTheme.success)
            StatPill(title: "Toplam", value: roundWords.count, color: BlitzTheme.muted)
        }
    }

    private var finishButton: some View {
        Button(action: finishGame) {
            BlitzButtonLabel(title: "Bitir", icon: "flag.fill")
        }
        .blitzButton(tint: BlitzTheme.accent)
    }

    private var grid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(roundWords) { word in
                tile(for: word)
            }
        }
    }

    private func tile(for word: VocabularyWord) -> some View {
        let prompt = prompt(for: word)
        let tint = tileTint(for: word)
        let isSelected = selectedWord?.id == word.id

        return Button {
            selectedWord = word
            answer = ""
            feedback = nil
        } label: {
            VStack(spacing: 8) {
                Text(prompt.questionText(for: word, language: learningLanguage))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(2)

                if isCompleted(word) {
                    Text(prompt.answerText(for: word, language: learningLanguage))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BlitzTheme.ink.opacity(0.86))
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                Text(statusText(for: word, prompt: prompt))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(tint ?? BlitzTheme.muted)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: isCompleted(word) ? 112 : (layout.isShort ? 72 : 86))
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint?.opacity(0.14) ?? BlitzTheme.surface)
                    .stroke(isSelected ? BlitzTheme.primary : (tint?.opacity(0.5) ?? .clear), lineWidth: isSelected ? 2 : 1.5)
            }
            .shadow(color: BlitzTheme.cardShadow, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(isCompleted(word))
    }

    private var placeholderPanel: some View {
        BlitzCard {
            VStack(spacing: 10) {
                Image(systemName: "hand.tap.fill")
                    .font(.largeTitle)
                    .foregroundStyle(BlitzTheme.accent)
                Text("Soldan bir kart seç")
                    .font(.headline)
                    .foregroundStyle(BlitzTheme.ink)
                if let feedback {
                    Text(feedback.text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 180)
        }
    }

    private func answerPanel(for word: VocabularyWord) -> some View {
        let prompt = prompt(for: word)

        return VStack(spacing: 16) {
            BlitzCard {
                VStack(spacing: 14) {
                    Text(prompt.questionText(for: word, language: learningLanguage))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.58)
                        .foregroundStyle(BlitzTheme.ink)

                    if let sentence = prompt.sentenceText(for: word, language: learningLanguage) {
                        Text(sentence)
                            .font(.body)
                            .foregroundStyle(BlitzTheme.muted)
                    }

                    Text("Hak: \(Self.maxAttempts - attempts[word.id, default: 0])")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BlitzTheme.accent)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }

            TextField(prompt.placeholder(for: learningLanguage), text: $answer)
                .blitzAnswerField()
                .onSubmit { submit(word) }

            Button { submit(word) } label: {
                BlitzButtonLabel(title: "Kontrol Et", icon: "arrow.right")
            }
            .blitzButton()
            .disabled(answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let feedback {
                Text(feedback.text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(feedback.isCorrect ? BlitzTheme.success : BlitzTheme.danger)
            }
        }
    }

    private func submit(_ word: VocabularyWord) {
        guard !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, monetization.spend() else { return }
        let wrongSoFar = attempts[word.id, default: 0]
        let prompt = prompt(for: word)
        let solution = prompt.answerText(for: word, language: learningLanguage)
        let given = answer
        answer = ""

        if prompt.matches(given, word: word, language: learningLanguage) {
            solved.insert(word.id)
            score += [5, 3, 1][min(wrongSoFar, 2)]
            feedback = Feedback(text: "Doğru: \(solution)", isCorrect: true)
            selectedWord = nil
            return
        }

        attempts[word.id] = wrongSoFar + 1
        if wrongSoFar + 1 >= Self.maxAttempts {
            failed.insert(word.id)
            score -= 3
            feedback = Feedback(text: "Hak bitti: \(solution)", isCorrect: false)
            selectedWord = nil
        } else {
            feedback = Feedback(text: "Yanlış. Kalan hak: \(Self.maxAttempts - wrongSoFar - 1)", isCorrect: false)
        }
    }

    private func finishGame() {
        finishedAt = Date()
        isNewBest = !hasBestScore || score > bestScore
        if isNewBest {
            bestScore = score
            hasBestScore = true
        }
        isFinished = true
        selectedWord = nil
    }

    private func newRound() {
        selectedWord = nil
        answer = ""
        solved = []
        failed = []
        attempts = [:]
        roundWords = Array(words.shuffled().prefix(Self.roundSize))
        let directions = roundWords.indices.map { $0.isMultiple(of: 2) ? WordHuntPrompt.targetToTurkish : .turkishToTarget }.shuffled()
        prompts = Dictionary(uniqueKeysWithValues: zip(roundWords.map(\.id), directions))
        score = 0
        feedback = nil
        isFinished = false
    }

    private var resultView: some View {
        VStack(spacing: 18) {
            ResultCard(
                title: "Kelime Avı Sonucu",
                score: score,
                detail: isNewBest ? "Yeni rekor" : "Rekorun: \(bestScore) puan",
                finishedAt: finishedAt,
                onReplay: newRound
            )

            HStack(spacing: 10) {
                StatPill(title: "Doğru", value: solved.count, color: BlitzTheme.success)
                StatPill(title: "Kaçan", value: failed.count, color: BlitzTheme.danger)
                StatPill(title: "Toplam", value: roundWords.count, color: BlitzTheme.muted)
            }

            Spacer()
        }
        .frame(maxWidth: 520)
        .padding(20)
    }

    private func prompt(for word: VocabularyWord) -> WordHuntPrompt {
        prompts[word.id, default: .targetToTurkish]
    }

    private func isCompleted(_ word: VocabularyWord) -> Bool {
        solved.contains(word.id) || failed.contains(word.id)
    }

    private func statusText(for word: VocabularyWord, prompt: WordHuntPrompt) -> String {
        if solved.contains(word.id) { return ["İlk hak", "2. hak", "3. hak"][min(attempts[word.id, default: 0], 2)] }
        if failed.contains(word.id) { return "Bilemedin" }
        return prompt.label(for: learningLanguage)
    }

    /// Çözülen/kaçan kartın rengi; açık kartlar için `nil`.
    private func tileTint(for word: VocabularyWord) -> Color? {
        if solved.contains(word.id) { return attempts[word.id, default: 0] == 0 ? BlitzTheme.success : BlitzTheme.accent }
        if failed.contains(word.id) { return BlitzTheme.danger }
        return nil
    }
}

private struct Feedback {
    var text: String
    var isCorrect: Bool
}

private enum WordHuntPrompt {
    case targetToTurkish
    case turkishToTarget

    func label(for language: LearningLanguage) -> String {
        switch self {
        case .targetToTurkish: language.shortCode
        case .turkishToTarget: "TR"
        }
    }

    func placeholder(for language: LearningLanguage) -> String {
        switch self {
        case .targetToTurkish: "Türkçe çevirisini yaz..."
        case .turkishToTarget: "\(language.title) karşılığını yaz..."
        }
    }

    func questionText(for word: VocabularyWord, language: LearningLanguage) -> String {
        switch self {
        case .targetToTurkish: word.targetTerm(for: language)
        case .turkishToTarget: word.turkish
        }
    }

    func sentenceText(for word: VocabularyWord, language: LearningLanguage) -> String? {
        switch self {
        case .targetToTurkish: word.targetSentence(for: language)
        case .turkishToTarget: word.turkishSentence
        }
    }

    func answerText(for word: VocabularyWord, language: LearningLanguage) -> String {
        switch self {
        case .targetToTurkish: word.turkish
        case .turkishToTarget: word.targetTerm(for: language)
        }
    }

    func matches(_ answer: String, word: VocabularyWord, language: LearningLanguage) -> Bool {
        switch self {
        case .targetToTurkish:
            word.strictlyMatchesTurkish(answer)
        case .turkishToTarget:
            word.strictlyMatchesTarget(answer, language: language)
        }
    }
}

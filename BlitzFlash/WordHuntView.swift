import SwiftUI

struct WordHuntView: View {
    var words: [VocabularyWord]

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
    @State private var feedback: String?
    @State private var isFinished = false
    @State private var finishedAt = Date()
    @State private var isNewBest = false

    private var activeWords: [VocabularyWord] {
        roundWords.isEmpty ? Array(words.prefix(15)) : roundWords
    }

    var body: some View {
        Group {
            if isFinished {
                resultView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            StatPill(title: "Puan", value: score, color: BlitzTheme.primary)
                            StatPill(title: "Bitti", value: solved.count + failed.count, color: BlitzTheme.success)
                            StatPill(title: "Toplam", value: activeWords.count, color: BlitzTheme.muted)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(activeWords) { word in
                                let prompt = prompt(for: word)

                                Button {
                                    selectedWord = word
                                    answer = ""
                                    feedback = nil
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(prompt.questionText(for: word))
                                            .font(.subheadline.weight(.bold))
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(BlitzTheme.ink)
                                            .lineLimit(2)

                                        Text(statusText(for: word, prompt: prompt))
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(BlitzTheme.muted)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 86)
                                    .padding(8)
                                    .background(tileColor(for: word))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(tileBorder(for: word), lineWidth: 1)
                                    }
                                    .shadow(color: tileBorder(for: word).opacity(0.18), radius: 10, x: 0, y: 0)
                                }
                                .buttonStyle(.plain)
                                .disabled(solved.contains(word.id) || failed.contains(word.id))
                            }
                        }

                        Button {
                            finishGame()
                        } label: {
                            Label("Bitir", systemImage: "flag.fill")
                                .font(.headline.weight(.bold))
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BlitzProminentButton(tint: BlitzTheme.accent, darkText: true))
                    }
                    .padding(20)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .blitzScreen()
        .navigationTitle("Kelime Avı")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            preparePromptsIfNeeded()
        }
        .sheet(item: $selectedWord) { word in
            huntSheet(for: word)
        }
    }

    private func huntSheet(for word: VocabularyWord) -> some View {
        let prompt = prompt(for: word)

        return NavigationStack {
            VStack(spacing: 18) {
                BlitzCard(glow: BlitzTheme.accent) {
                    VStack(spacing: 14) {
                        Text(prompt.questionText(for: word))
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .minimumScaleFactor(0.58)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.ink)
                            .shadow(color: BlitzTheme.accent.opacity(0.22), radius: 18, x: 0, y: 0)

                        Text(prompt.sentenceText(for: word))
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.muted)

                        Text("Hak: \(3 - attempts[word.id, default: 0])")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(BlitzTheme.accent)
                    }
                    .frame(maxWidth: .infinity)
                }

                TextField(prompt.placeholder, text: $answer)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit { submit(word) }
                    .padding(14)
                    .foregroundStyle(BlitzTheme.ink)
                    .background(BlitzTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(BlitzTheme.accent.opacity(0.25), lineWidth: 1)
                    }

                Button("Kontrol Et") {
                    submit(word)
                }
                .font(.headline)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .buttonStyle(BlitzProminentButton(tint: BlitzTheme.accent, darkText: true))

                if let feedback {
                    Text(feedback)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(feedback.hasPrefix("Doğru") ? BlitzTheme.success : BlitzTheme.danger)
                }

                Spacer()
            }
            .padding(20)
            .blitzScreen()
            .navigationTitle("Ceviri")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submit(_ word: VocabularyWord) {
        let currentAttempts = attempts[word.id, default: 0]
        let prompt = prompt(for: word)

        if prompt.matches(answer, word: word) {
            solved.insert(word.id)
            score += scoreForCorrectAnswer(afterWrongAttempts: currentAttempts)
            feedback = "Doğru: \(prompt.answerText(for: word))"
            selectedWord = nil
            return
        }

        attempts[word.id] = currentAttempts + 1
        if currentAttempts + 1 >= 3 {
            failed.insert(word.id)
            score -= 3
            feedback = "Hak bitti: \(prompt.answerText(for: word))"
            selectedWord = nil
        } else {
            feedback = "Yanlış. Kalan hak: \(3 - (currentAttempts + 1))"
        }
        answer = ""
    }

    private func scoreForCorrectAnswer(afterWrongAttempts wrongAttempts: Int) -> Int {
        switch wrongAttempts {
        case 0: 5
        case 1: 3
        default: 1
        }
    }

    private func finishGame() {
        finishedAt = Date()
        if !hasBestScore || score > bestScore {
            bestScore = score
            hasBestScore = true
            isNewBest = true
        } else {
            isNewBest = false
        }
        isFinished = true
        selectedWord = nil
    }

    private func restartGame() {
        selectedWord = nil
        answer = ""
        solved = []
        failed = []
        attempts = [:]
        roundWords = randomRoundWords()
        prompts = randomPrompts(for: roundWords)
        score = 0
        feedback = nil
        isFinished = false
        finishedAt = Date()
        isNewBest = false
    }

    private var resultView: some View {
        VStack(spacing: 18) {
            BlitzCard(glow: BlitzTheme.accent) {
                VStack(spacing: 14) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(BlitzTheme.accent)

                    Text("Kelime Avı Sonucu")
                        .font(.title2.weight(.black))
                        .foregroundStyle(BlitzTheme.ink)

                    Text("\(formattedDate(finishedAt)) • \(formattedTime(finishedAt))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)

                    Text("\(score) puan")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(score >= 0 ? BlitzTheme.success : BlitzTheme.danger)
                        .shadow(color: (score >= 0 ? BlitzTheme.success : BlitzTheme.danger).opacity(0.24), radius: 18, x: 0, y: 0)

                    Text(isNewBest ? "Yeni rekor" : "Rekorun: \(bestScore) puan")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(BlitzTheme.primary)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                StatPill(title: "Doğru", value: solved.count, color: BlitzTheme.success)
                StatPill(title: "Kaçan", value: failed.count, color: BlitzTheme.danger)
                StatPill(title: "Toplam", value: activeWords.count, color: BlitzTheme.muted)
            }

            Button {
                restartGame()
            } label: {
                Label("Tekrar Oyna", systemImage: "arrow.clockwise")
                    .font(.headline.weight(.bold))
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BlitzProminentButton(tint: BlitzTheme.secondary))

            Spacer()
        }
        .padding(20)
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.wide).year())
    }

    private func formattedTime(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute())
    }

    private func preparePromptsIfNeeded() {
        guard prompts.isEmpty else { return }
        roundWords = randomRoundWords()
        prompts = randomPrompts(for: roundWords)
    }

    private func randomRoundWords() -> [VocabularyWord] {
        Array(words.shuffled().prefix(15))
    }

    private func randomPrompts(for roundWords: [VocabularyWord]) -> [UUID: WordHuntPrompt] {
        let mixedPrompts = roundWords.indices
            .map { $0.isMultiple(of: 2) ? WordHuntPrompt.englishToTurkish : .turkishToEnglish }
            .shuffled()

        return Dictionary(uniqueKeysWithValues: zip(roundWords.map(\.id), mixedPrompts))
    }

    private func prompt(for word: VocabularyWord) -> WordHuntPrompt {
        prompts[word.id, default: .englishToTurkish]
    }

    private func statusText(for word: VocabularyWord, prompt: WordHuntPrompt) -> String {
        if solved.contains(word.id) { return "Doğru" }
        if failed.contains(word.id) { return "Bitti" }
        return prompt.label
    }

    private func tileColor(for word: VocabularyWord) -> Color {
        if solved.contains(word.id) { return BlitzTheme.success.opacity(0.18) }
        if failed.contains(word.id) { return BlitzTheme.danger.opacity(0.2) }
        return BlitzTheme.surface
    }

    private func tileBorder(for word: VocabularyWord) -> Color {
        if solved.contains(word.id) { return BlitzTheme.success.opacity(0.4) }
        if failed.contains(word.id) { return BlitzTheme.danger.opacity(0.4) }
        return BlitzTheme.primary.opacity(0.12)
    }
}

private enum WordHuntPrompt {
    case englishToTurkish
    case turkishToEnglish

    var label: String {
        switch self {
        case .englishToTurkish: "EN"
        case .turkishToEnglish: "TR"
        }
    }

    var placeholder: String {
        switch self {
        case .englishToTurkish: "Türkçe çevirisini yaz..."
        case .turkishToEnglish: "İngilizce karşılığını yaz..."
        }
    }

    func questionText(for word: VocabularyWord) -> String {
        switch self {
        case .englishToTurkish: word.english
        case .turkishToEnglish: word.turkish
        }
    }

    func sentenceText(for word: VocabularyWord) -> String {
        switch self {
        case .englishToTurkish: word.englishSentence
        case .turkishToEnglish: word.turkishSentence
        }
    }

    func answerText(for word: VocabularyWord) -> String {
        switch self {
        case .englishToTurkish: word.turkish
        case .turkishToEnglish: word.english
        }
    }

    func matches(_ answer: String, word: VocabularyWord) -> Bool {
        switch self {
        case .englishToTurkish:
            word.strictlyMatchesTurkish(answer)
        case .turkishToEnglish:
            word.strictlyMatchesEnglish(answer)
        }
    }
}

private extension VocabularyWord {
    func strictlyMatchesTurkish(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return acceptedAnswers.contains(normalized) || turkish.foldedForAnswer == normalized
    }

    func strictlyMatchesEnglish(_ answer: String) -> Bool {
        let normalized = answer.foldedForAnswer
        guard !normalized.isEmpty else { return false }
        return english.foldedForAnswer == normalized
    }
}

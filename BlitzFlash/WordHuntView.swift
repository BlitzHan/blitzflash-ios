import SwiftUI

struct WordHuntView: View {
    var words: [VocabularyWord]

    @State private var selectedWord: VocabularyWord?
    @State private var answer = ""
    @State private var solved: Set<UUID> = []
    @State private var failed: Set<UUID> = []
    @State private var attempts: [UUID: Int] = [:]
    @State private var score = 0
    @State private var feedback: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    StatPill(title: "Puan", value: score, color: BlitzTheme.primary)
                    StatPill(title: "Bitti", value: solved.count + failed.count, color: BlitzTheme.secondary)
                    StatPill(title: "Toplam", value: words.count, color: BlitzTheme.muted)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(words) { word in
                        Button {
                            selectedWord = word
                            answer = ""
                            feedback = nil
                        } label: {
                            VStack(spacing: 8) {
                                Text(word.english)
                                    .font(.subheadline.weight(.bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(BlitzTheme.ink)
                                    .lineLimit(2)

                                Text(statusText(for: word))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(BlitzTheme.muted)
                            }
                            .frame(maxWidth: .infinity, minHeight: 86)
                            .padding(8)
                            .background(tileColor(for: word))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(solved.contains(word.id) || failed.contains(word.id))
                    }
                }
            }
            .padding(20)
        }
        .background(BlitzTheme.surface)
        .navigationTitle("Kelime Avi")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedWord) { word in
            huntSheet(for: word)
        }
    }

    private func huntSheet(for word: VocabularyWord) -> some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(word.english)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)

                Text(word.englishSentence)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BlitzTheme.muted)

                TextField("Turkce cevirisini yaz...", text: $answer)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit { submit(word) }
                    .padding(14)
                    .background(BlitzTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button("Kontrol Et") {
                    submit(word)
                }
                .buttonStyle(.borderedProminent)

                if let feedback {
                    Text(feedback)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(feedback.hasPrefix("Dogru") ? BlitzTheme.secondary : BlitzTheme.warm)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Ceviri")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submit(_ word: VocabularyWord) {
        let currentAttempts = attempts[word.id, default: 0]
        if word.matches(answer) {
            solved.insert(word.id)
            score += max(3 - currentAttempts, 1)
            feedback = "Dogru: \(word.turkish)"
            selectedWord = nil
            return
        }

        attempts[word.id] = currentAttempts + 1
        if currentAttempts + 1 >= 3 {
            failed.insert(word.id)
            score -= 1
            feedback = "Hak bitti: \(word.turkish)"
            selectedWord = nil
        } else {
            feedback = "Yanlis. Kalan hak: \(3 - (currentAttempts + 1))"
        }
        answer = ""
    }

    private func statusText(for word: VocabularyWord) -> String {
        if solved.contains(word.id) { return "Dogru" }
        if failed.contains(word.id) { return "Bitti" }
        return "EN"
    }

    private func tileColor(for word: VocabularyWord) -> Color {
        if solved.contains(word.id) { return BlitzTheme.secondary.opacity(0.2) }
        if failed.contains(word.id) { return BlitzTheme.warm.opacity(0.2) }
        return Color(uiColor: .systemBackground)
    }
}

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
                    StatPill(title: "Bitti", value: solved.count + failed.count, color: BlitzTheme.success)
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
            }
            .padding(20)
        }
        .scrollContentBackground(.hidden)
        .blitzScreen()
        .navigationTitle("Kelime Avı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedWord) { word in
            huntSheet(for: word)
        }
    }

    private func huntSheet(for word: VocabularyWord) -> some View {
        NavigationStack {
            VStack(spacing: 18) {
                BlitzCard(glow: BlitzTheme.accent) {
                    VStack(spacing: 14) {
                        Text(word.english)
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)
                            .shadow(color: BlitzTheme.accent.opacity(0.22), radius: 18, x: 0, y: 0)

                        Text(word.englishSentence)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                    .frame(maxWidth: .infinity)
                }

                TextField("Türkçe çevirisini yaz...", text: $answer)
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
        if word.matches(answer) {
            solved.insert(word.id)
            score += max(3 - currentAttempts, 1)
            feedback = "Doğru: \(word.turkish)"
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
            feedback = "Yanlış. Kalan hak: \(3 - (currentAttempts + 1))"
        }
        answer = ""
    }

    private func statusText(for word: VocabularyWord) -> String {
        if solved.contains(word.id) { return "Doğru" }
        if failed.contains(word.id) { return "Bitti" }
        return "EN"
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

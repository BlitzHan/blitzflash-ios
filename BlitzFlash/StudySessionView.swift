import SwiftUI

struct FreeStudyView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var correct = 0
    @State private var wrong = 0
    @State private var isShowingAnswer = false

    private var currentWord: VocabularyWord {
        words[min(currentIndex, words.count - 1)]
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Bildim", value: correct, color: BlitzTheme.success)
                StatPill(title: "Bilemedim", value: wrong, color: BlitzTheme.danger)
                StatPill(title: "Toplam", value: words.count, color: BlitzTheme.primary)
            }

            ProgressView(value: Double(currentIndex + 1), total: Double(words.count))
                .tint(BlitzTheme.primary)

            Text("\(currentIndex + 1) / \(words.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BlitzTheme.muted)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isShowingAnswer.toggle()
                }
            } label: {
                VStack(spacing: 18) {
                    Text(isShowingAnswer ? "Turkce" : "English")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isShowingAnswer ? BlitzTheme.secondary : BlitzTheme.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(isShowingAnswer ? BlitzTheme.secondary.opacity(0.2) : BlitzTheme.primary.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Text(isShowingAnswer ? currentWord.turkish : currentWord.english)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.ink)
                        .shadow(color: (isShowingAnswer ? BlitzTheme.secondary : BlitzTheme.primary).opacity(0.24), radius: 18, x: 0, y: 0)

                    Text(isShowingAnswer ? currentWord.turkishSentence : currentWord.englishSentence)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.muted)
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 320)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BlitzTheme.cardGradient)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke((isShowingAnswer ? BlitzTheme.secondary : BlitzTheme.primary).opacity(0.22), lineWidth: 1)
                        }
                )
                .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 16)
                .shadow(color: (isShowingAnswer ? BlitzTheme.secondary : BlitzTheme.primary).opacity(0.16), radius: 32, x: 0, y: 0)
            }
            .buttonStyle(.plain)

            Text("Karti cevirmek icin dokun.")
                .font(.footnote)
                .foregroundStyle(BlitzTheme.muted)

            Spacer()

            HStack(spacing: 12) {
                StudyAction(title: "Bilemedim", icon: "xmark", tint: BlitzTheme.warm, darkText: true) {
                    wrong += 1
                    nextCard()
                }

                StudyAction(title: "Bildim", icon: "checkmark", tint: BlitzTheme.secondary) {
                    correct += 1
                    nextCard()
                }
            }
        }
        .padding(20)
        .blitzScreen()
        .navigationTitle("Serbest Mod")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingAnswer = false
            currentIndex = (currentIndex + 1) % words.count
        }
    }
}

struct StatPill: View {
    var title: String
    var value: Int
    var color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.headline.weight(.bold))
                .foregroundStyle(color)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(BlitzTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(BlitzTheme.surface.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                }
        )
        .shadow(color: color.opacity(0.12), radius: 12, x: 0, y: 0)
    }
}

private struct StudyAction: View {
    var title: String
    var icon: String
    var tint: Color
    var darkText = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(BlitzProminentButton(tint: tint, darkText: darkText))
    }
}

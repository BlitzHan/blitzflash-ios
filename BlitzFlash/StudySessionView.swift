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
                StatPill(title: "Bildim", value: correct, color: BlitzTheme.secondary)
                StatPill(title: "Bilemedim", value: wrong, color: BlitzTheme.warm)
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

                    Text(isShowingAnswer ? currentWord.turkish : currentWord.english)
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.ink)

                    Text(isShowingAnswer ? currentWord.turkishSentence : currentWord.englishSentence)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.muted)
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 320)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)

            Text("Karti cevirmek icin dokun.")
                .font(.footnote)
                .foregroundStyle(BlitzTheme.muted)

            Spacer()

            HStack(spacing: 12) {
                StudyAction(title: "Bilemedim", icon: "xmark", tint: BlitzTheme.warm) {
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
        .background(BlitzTheme.surface)
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct StudyAction: View {
    var title: String
    var icon: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
    }
}

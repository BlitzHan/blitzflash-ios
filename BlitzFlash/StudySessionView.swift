import SwiftUI

struct FreeStudyView: View {
    var words: [VocabularyWord]

    @State private var currentIndex = 0
    @State private var correct = 0
    @State private var wrong = 0
    @State private var isShowingAnswer = false
    @State private var dragOffset = CGSize.zero
    @State private var isCardPressed = false
    @State private var prompts: [CardPrompt]

    init(words: [VocabularyWord]) {
        self.words = words
        _prompts = State(initialValue: words.map { CardPrompt(word: $0, startsWithEnglish: Bool.random()) })
    }

    private var currentPrompt: CardPrompt {
        prompts[min(currentIndex, prompts.count - 1)]
    }

    private var currentWord: VocabularyWord {
        currentPrompt.word
    }

    private var showingEnglish: Bool {
        isShowingAnswer ? !currentPrompt.startsWithEnglish : currentPrompt.startsWithEnglish
    }

    private var languageLabel: String {
        showingEnglish ? "English" : "Türkçe"
    }

    private var displayedWord: String {
        showingEnglish ? currentWord.english : currentWord.turkish
    }

    private var displayedSentence: String {
        showingEnglish ? currentWord.englishSentence : currentWord.turkishSentence
    }

    private var dragProgress: Double {
        min(abs(dragOffset.width) / 140, 1)
    }

    private var activeGlow: Color {
        if dragOffset.width > 18 { return BlitzTheme.success }
        if dragOffset.width < -18 { return BlitzTheme.danger }
        return isShowingAnswer ? BlitzTheme.secondary : BlitzTheme.primary
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                StatPill(title: "Bildim", value: correct, color: BlitzTheme.success)
                StatPill(title: "Bilemedim", value: wrong, color: BlitzTheme.danger)
                StatPill(title: "Toplam", value: prompts.count, color: BlitzTheme.primary)
            }

            ProgressView(value: Double(currentIndex + 1), total: Double(prompts.count))
                .tint(BlitzTheme.primary)

            Text("\(currentIndex + 1) / \(prompts.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BlitzTheme.muted)

            Spacer()

            studyCard

            Text("Kartı açmak için dokun. Sağa Bildim, sola Bilemedim.")
                .font(.footnote)
                .foregroundStyle(BlitzTheme.muted)

            Spacer()

            HStack(spacing: 12) {
                StudyAction(title: "Bilemedim", icon: "arrow.counterclockwise", tint: BlitzTheme.danger) {
                    wrong += 1
                    nextCard()
                }

                StudyAction(title: "Bildim", icon: "bolt.fill", tint: BlitzTheme.success) {
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

    private var studyCard: some View {
        ZStack {
            VStack(spacing: 0) {
                Text(languageLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(showingEnglish ? BlitzTheme.primary : BlitzTheme.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(showingEnglish ? BlitzTheme.primary.opacity(0.18) : BlitzTheme.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, alignment: .top)

                Spacer(minLength: 12)

                Text(displayedWord)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BlitzTheme.ink)
                    .shadow(color: activeGlow.opacity(0.24), radius: 18, x: 0, y: 0)
                    .contentTransition(.opacity)
                    .lineLimit(3)
                    .minimumScaleFactor(0.62)
                    .frame(maxWidth: .infinity, minHeight: 118, alignment: .center)

                Spacer(minLength: 12)

                Text(displayedSentence)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BlitzTheme.muted)
                    .contentTransition(.opacity)
                    .lineLimit(4)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .top)
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 320)
            .background(cardBackground)
            .scaleEffect(isCardPressed ? 0.975 : 1)
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 18)))
            .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 16)
            .shadow(color: activeGlow.opacity(0.16), radius: 32, x: 0, y: 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isCardPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.86), value: isShowingAnswer)
            .animation(.spring(response: 0.3, dampingFraction: 0.86), value: currentIndex)

            swipeStamp(title: "BILDIM", icon: "checkmark", color: BlitzTheme.success)
                .opacity(dragOffset.width > 0 ? dragProgress : 0)
                .rotationEffect(.degrees(-12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)

            swipeStamp(title: "BILEMEDIM", icon: "xmark", color: BlitzTheme.danger)
                .opacity(dragOffset.width < 0 ? dragProgress : 0)
                .rotationEffect(.degrees(12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(24)
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) {
                isCardPressed = true
                isShowingAnswer.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    isCardPressed = false
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let width = value.translation.width
                    if width > 115 {
                        correct += 1
                        flingAndAdvance(toRight: true)
                    } else if width < -115 {
                        wrong += 1
                        flingAndAdvance(toRight: false)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(BlitzTheme.cardGradient)
            .overlay(alignment: .top) {
                LinearGradient(colors: [.clear, activeGlow.opacity(0.9), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(activeGlow.opacity(0.26), lineWidth: 1)
            }
    }

    private func swipeStamp(title: String, icon: String, color: Color) -> some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.black))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(color.opacity(0.85), lineWidth: 2)
            }
            .shadow(color: color.opacity(0.45), radius: 12, x: 0, y: 0)
    }

    private func flingAndAdvance(toRight: Bool) {
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(width: toRight ? 620 : -620, height: 42)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            nextCard()
            dragOffset = CGSize(width: toRight ? -40 : 40, height: 0)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                dragOffset = .zero
            }
        }
    }

    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isShowingAnswer = false
            currentIndex = (currentIndex + 1) % prompts.count
        }
    }
}

private struct CardPrompt {
    var word: VocabularyWord
    var startsWithEnglish: Bool
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

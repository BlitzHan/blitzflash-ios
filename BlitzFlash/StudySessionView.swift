import SwiftUI

struct FreeStudyView: View {
    var words: [VocabularyWord]
    var learningLanguage: LearningLanguage

    @Environment(MonetizationStore.self) private var monetization
    @Environment(\.blitzLayout) private var layout

    @State private var currentIndex = 0
    @State private var correct = 0
    @State private var wrong = 0
    @State private var isShowingAnswer = false
    @State private var dragOffset = CGSize.zero
    @State private var prompts: [CardPrompt]
    @State private var history: [AnsweredCard] = []
    @State private var delay = Delay()

    init(words: [VocabularyWord], learningLanguage: LearningLanguage = .english) {
        self.words = words
        self.learningLanguage = learningLanguage
        _prompts = State(initialValue: Self.randomPrompts(from: words))
    }

    private var currentPrompt: CardPrompt {
        prompts[min(currentIndex, prompts.count - 1)]
    }

    private var currentWord: VocabularyWord {
        currentPrompt.word
    }

    private var showingTargetLanguage: Bool {
        isShowingAnswer != currentPrompt.startsWithTargetLanguage
    }

    private var dragProgress: Double {
        min(abs(dragOffset.width) / 140, 1)
    }

    private var activeTint: Color {
        if dragOffset.width > 18 { return BlitzTheme.success }
        if dragOffset.width < -18 { return BlitzTheme.danger }
        return .clear
    }

    var body: some View {
        VStack(spacing: layout.isShort ? 12 : 18) {
            if !layout.isSplit && !layout.hasSideRail {
                statsRow
            }

            // Dikte (yarı açık) üst yarı yalnız karta ayrılır; ipucu çizginin altına iner.
            AdaptiveSplit {
                Spacer(minLength: 0)
                studyCard
                if !layout.isTall { hint }
                Spacer(minLength: 0)
            } secondary: {
                if layout.isTall { hint }
                if layout.isSplit { statsRow }
                progress
                if layout.isSplit { historyList }
                Spacer(minLength: 0)
                actionButtons
            }
        }
        .padding(layout.isShort ? 16 : 20)
        .blitzScreen()
        .navigationTitle(BlitzMode.free.title)
        .navigationBarTitleDisplayMode(.inline)
        .sideRail(layout) { statsRow }
        .sensoryFeedback(.success, trigger: correct)
        .sensoryFeedback(.impact(weight: .light), trigger: wrong)
        .onDisappear { delay.cancel() }
    }

    private var hint: some View {
        Text("Kartı açmak için dokun. Sağa Bildim, sola Bilemedim.")
            .font(.footnote)
            .foregroundStyle(BlitzTheme.muted)
            .multilineTextAlignment(.center)
    }

    private var statsRow: some View {
        StatGroup {
            StatPill(title: "Bildim", value: correct, color: BlitzTheme.success)
            StatPill(title: "Bilemedim", value: wrong, color: BlitzTheme.danger)
            StatPill(title: "Toplam", value: prompts.count, color: BlitzTheme.primary)
        }
    }

    private var progress: some View {
        VStack(spacing: 6) {
            ProgressView(value: Double(currentIndex + 1), total: Double(prompts.count))
                .tint(BlitzTheme.primary)
            Text("\(currentIndex + 1) / \(prompts.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BlitzTheme.muted)
                .monospacedDigit()
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button { answer(knew: false) } label: {
                BlitzButtonLabel(title: "Bilemedim", icon: "arrow.counterclockwise")
            }
            .blitzButton(tint: BlitzTheme.danger)

            Button { answer(knew: true) } label: {
                BlitzButtonLabel(title: "Bildim", icon: "bolt.fill")
            }
            .blitzButton(tint: BlitzTheme.success)
        }
    }

    /// Duo iç ekranında ikincil bölmede son kartlar: tekrar göz atmak için.
    /// Üst üste düzende alt yarı kısa olduğundan son üç kart.
    private var historyList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Son kartlar")
                .font(.headline)
                .foregroundStyle(BlitzTheme.ink)

            if history.isEmpty {
                Text("Cevapladığın kartlar burada listelenir.")
                    .font(.subheadline)
                    .foregroundStyle(BlitzTheme.muted)
            }

            ForEach(history.prefix(layout.isTall ? 3 : 8)) { card in
                HStack(spacing: 10) {
                    Image(systemName: card.knew ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(card.knew ? BlitzTheme.success : BlitzTheme.danger)
                    Text(card.word.targetTerm(for: learningLanguage))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.ink)
                    Spacer(minLength: 8)
                    Text(card.word.turkish)
                        .font(.subheadline)
                        .foregroundStyle(BlitzTheme.muted)
                        .lineLimit(1)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BlitzTheme.surface, in: .rect(cornerRadius: 16))
    }

    private var studyCard: some View {
        let sentence = showingTargetLanguage ? currentWord.targetSentence(for: learningLanguage) : currentWord.turkishSentence
        let pronunciation = showingTargetLanguage ? currentWord.targetPronunciation(for: learningLanguage) : nil
        let labelTint = showingTargetLanguage ? BlitzTheme.primary : BlitzTheme.secondary

        return ZStack {
            VStack(spacing: 0) {
                Text(showingTargetLanguage ? learningLanguage.nativeTitle : "Türkçe")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(labelTint)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(labelTint.opacity(0.12), in: .capsule)
                    .frame(height: 44)

                Spacer(minLength: 12)

                Text(showingTargetLanguage ? currentWord.targetTerm(for: learningLanguage) : currentWord.turkish)
                    .font(.system(size: layout.isShort ? 32 : 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.62)
                    .frame(maxWidth: .infinity, minHeight: layout.isShort ? 84 : 118)

                if let pronunciation {
                    Text("[ \(pronunciation) ]")
                        .font(.callout.italic())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BlitzTheme.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .padding(.top, 4)
                }

                Spacer(minLength: 12)

                Text(sentence ?? " ")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BlitzTheme.muted)
                    .lineLimit(4)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity, minHeight: layout.isShort ? 60 : 86, alignment: .top)
            }
            .contentTransition(.opacity)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: layout.isShort || layout.isTall ? 250 : 320)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(BlitzTheme.surface)
                    .stroke(activeTint.opacity(0.6), lineWidth: 1.5)
            }
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 18)))
            .shadow(color: BlitzTheme.cardShadow, radius: 16, x: 0, y: 8)
            .animation(.spring(response: 0.3, dampingFraction: 0.86), value: isShowingAnswer)
            .animation(.spring(response: 0.3, dampingFraction: 0.86), value: currentIndex)

            swipeStamp(title: "BİLDİM", icon: "checkmark", color: BlitzTheme.success)
                .opacity(dragOffset.width > 0 ? dragProgress : 0)
                .rotationEffect(.degrees(-12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(24)

            swipeStamp(title: "BİLEMEDİM", icon: "xmark", color: BlitzTheme.danger)
                .opacity(dragOffset.width < 0 ? dragProgress : 0)
                .rotationEffect(.degrees(12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(24)
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(.rect(cornerRadius: 20))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) { isShowingAnswer.toggle() }
        }
        .sensoryFeedback(.selection, trigger: isShowingAnswer)
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    let width = value.translation.width
                    if abs(width) > 115 {
                        answer(knew: width > 0, fling: true)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { dragOffset = .zero }
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Kartın diğer yüzünü gösterir")
    }

    private func swipeStamp(title: String, icon: String, color: Color) -> some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(color.opacity(0.85), lineWidth: 2)
            }
    }

    private func answer(knew: Bool, fling: Bool = false) {
        guard monetization.spend() else {
            withAnimation(.spring) { dragOffset = .zero }
            return
        }
        if knew { correct += 1 } else { wrong += 1 }
        withAnimation(.snappy) {
            history.insert(AnsweredCard(word: currentWord, knew: knew), at: 0)
            history = Array(history.prefix(8))
        }

        guard fling else { return nextCard() }
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(width: knew ? 620 : -620, height: 42)
        }
        delay.run(after: 0.2) {
            nextCard()
            dragOffset = CGSize(width: knew ? -40 : 40, height: 0)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) { dragOffset = .zero }
        }
    }

    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isShowingAnswer = false
            if currentIndex + 1 >= prompts.count {
                prompts = Self.randomPrompts(from: words)
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }
    }

    private static func randomPrompts(from words: [VocabularyWord]) -> [CardPrompt] {
        words.shuffled().map { CardPrompt(word: $0, startsWithTargetLanguage: Bool.random()) }
    }
}

private struct CardPrompt {
    var word: VocabularyWord
    var startsWithTargetLanguage: Bool
}

private struct AnsweredCard: Identifiable {
    let id = UUID()
    var word: VocabularyWord
    var knew: Bool
}

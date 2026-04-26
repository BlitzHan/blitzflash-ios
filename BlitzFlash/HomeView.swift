import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BrandHeader(wordCount: words.count)

                    VStack(spacing: 12) {
                        ForEach(BlitzMode.allCases) { mode in
                            NavigationLink {
                                destination(for: mode)
                            } label: {
                                ModeCard(mode: mode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .blitzScreen()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func destination(for mode: BlitzMode) -> some View {
        switch mode {
        case .free:
            FreeStudyView(words: words.shuffled())
        case .typing:
            TypingModeView(words: words.shuffled())
        case .sentence:
            SentenceModeView(words: words.shuffled())
        case .hunt:
            WordHuntView(words: Array(words.shuffled().prefix(15)))
        }
    }
}

private struct BrandHeader: View {
    var wordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                LightningBadge()

                VStack(alignment: .leading, spacing: 5) {
                    Text("BlitzFlash")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BlitzTheme.primaryLight, BlitzTheme.primary, BlitzTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: BlitzTheme.primary.opacity(0.42), radius: 16, x: 0, y: 0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Hızlı tekrar. Net skor. 800 kelime.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(wordCount)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BlitzTheme.accent, BlitzTheme.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("kelimelik havuz")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.ink)

                    Spacer()
                }

                Text("Bir mod seç, kısa bir tur aç, ritmini yakala.")
                    .font(.subheadline)
                    .foregroundStyle(BlitzTheme.muted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BlitzTheme.surface.opacity(0.78))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BlitzTheme.primary.opacity(0.14), lineWidth: 1)
                    }
            )
        }
    }
}

private struct LightningBadge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BlitzTheme.accent, BlitzTheme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .shadow(color: BlitzTheme.accent.opacity(0.42), radius: 18, x: 0, y: 0)

            LightningGlyph(size: 34)
                .foregroundStyle(BlitzTheme.background)
        }
    }
}

private struct ModeCard: View {
    var mode: BlitzMode

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: glowColor.opacity(0.28), radius: 14, x: 0, y: 0)

                Image(systemName: mode.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(mode == .hunt ? BlitzTheme.background : .white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(mode.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(mode.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BlitzTheme.muted)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(glowColor.opacity(0.14))
                    .frame(width: 34, height: 34)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(glowColor)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(BlitzTheme.cardGradient)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(glowColor)
                        .frame(width: 4)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(glowColor.opacity(0.18), lineWidth: 1)
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 10)
    }

    private var glowColor: Color {
        switch mode {
        case .free: BlitzTheme.primary
        case .typing: BlitzTheme.secondary
        case .sentence: BlitzTheme.success
        case .hunt: BlitzTheme.accent
        }
    }

    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [glowColor, glowColor.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

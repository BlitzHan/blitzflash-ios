import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    BrandHeader()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(BlitzMode.allCases) { mode in
                            NavigationLink {
                                destination(for: mode)
                            } label: {
                                ModeCard(mode: mode)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    BlitzCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("\(words.count) BBC Essential kelime", systemImage: "books.vertical.fill")
                                .font(.headline)
                                .foregroundStyle(BlitzTheme.ink)

                            Text("Her kartta Ingilizce kelime, Turkce anlam, ornek cumle ve ceviri bulunur. Veriler web uygulamasindaki kelime dosyalarindan native iOS'a tasindi.")
                                .font(.subheadline)
                                .foregroundStyle(BlitzTheme.muted)
                        }
                    }
                }
                .padding(20)
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
            FreeStudyView(words: Array(words.shuffled().prefix(40)))
        case .typing:
            TypingModeView(words: Array(words.shuffled().prefix(80)))
        case .sentence:
            SentenceModeView(words: Array(words.shuffled().prefix(25)))
        case .hunt:
            WordHuntView(words: Array(words.shuffled().prefix(30)))
        }
    }
}

private struct BrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                LightningGlyph(size: 28)
                    .foregroundStyle(BlitzTheme.background)
                    .frame(width: 48, height: 48)
                    .background(BlitzTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: BlitzTheme.accent.opacity(0.45), radius: 16, x: 0, y: 0)

                Text("BlitzFlash")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BlitzTheme.primaryLight, BlitzTheme.primary, BlitzTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: BlitzTheme.primary.opacity(0.45), radius: 16, x: 0, y: 0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text("Modunu sec, kelime ritmini baslat.")
                .font(.headline.weight(.semibold))
                .foregroundStyle(BlitzTheme.accent)

            Text("Ingilizce kelimeleri kart, sureli tahmin, cumle ve grid oyunu ile calis.")
                .font(.subheadline)
                .foregroundStyle(BlitzTheme.muted)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

private struct ModeCard: View {
    var mode: BlitzMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconGradient)
                    .frame(width: 42, height: 42)
                    .shadow(color: glowColor.opacity(0.28), radius: 14, x: 0, y: 0)

                Image(systemName: mode.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(mode == .hunt ? BlitzTheme.background : .white)
            }

            Text(mode.title)
                .font(.headline)
                .foregroundStyle(BlitzTheme.ink)
                .lineLimit(2)

            Text(mode.subtitle)
                .font(.caption)
                .foregroundStyle(BlitzTheme.muted)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(BlitzTheme.cardGradient)
                .overlay(alignment: .top) {
                    LinearGradient(colors: [.clear, glowColor.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(height: 2)
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

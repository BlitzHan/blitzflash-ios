import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero

                    SectionHeader(title: "Oyun Modlari")

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

                    SectionHeader(title: "Kelime Havuzu")

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
            .navigationTitle("BlitzFlash")
        }
    }

    private var hero: some View {
        BlitzCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingilizce Kelime Ogren")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BlitzTheme.primary)

                        Text("BlitzFlash")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)
                            .shadow(color: BlitzTheme.primary.opacity(0.35), radius: 16, x: 0, y: 0)

                        Text("Hizli, oyunlu, native")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BlitzTheme.accent)
                    }

                    Spacer()

                    LightningGlyph(size: 30)
                        .foregroundStyle(BlitzTheme.background)
                        .frame(width: 54, height: 54)
                        .background(BlitzTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: BlitzTheme.accent.opacity(0.45), radius: 16, x: 0, y: 0)
                }

                Text("Serbest kart calisma, 60 saniyelik yazarak tahmin, cumle tamamlama ve kelime avi modlariyla calismaya basla.")
                    .font(.body)
                    .foregroundStyle(BlitzTheme.muted)

                NavigationLink {
                    FreeStudyView(words: Array(words.shuffled().prefix(30)))
                } label: {
                    Label("Hemen Basla", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(BlitzProminentButton(tint: BlitzTheme.primary))
            }
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

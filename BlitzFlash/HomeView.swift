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
            .background(BlitzTheme.surface)
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

                        Text("Hizli, oyunlu, native")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(BlitzTheme.ink)
                    }

                    Spacer()

                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(BlitzTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                .buttonStyle(.borderedProminent)
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
            Image(systemName: mode.icon)
                .font(.title2)
                .foregroundStyle(BlitzTheme.primary)

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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

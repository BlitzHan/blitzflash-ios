import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    BrandHeader()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
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
            FreeStudyView(words: words.shuffled())
        case .typing:
            TypingModeView(words: words.shuffled())
        case .sentence:
            SentenceModeView(words: words.shuffled())
        case .hunt:
            WordHuntView(words: Array(words.shuffled().prefix(30)))
        }
    }
}

private struct BrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(BlitzTheme.accent)
                        .frame(width: 58, height: 58)
                        .shadow(color: BlitzTheme.accent.opacity(0.45), radius: 18, x: 0, y: 0)

                    LightningGlyph(size: 34)
                        .foregroundStyle(BlitzTheme.background)
                }

                VStack(alignment: .leading, spacing: 4) {
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
                        .minimumScaleFactor(0.72)

                    Text("Kelime ritmini seç.")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.accent)
                }
            }

            HStack(spacing: 8) {
                MiniBadge(text: "Kart")
                MiniBadge(text: "Tahmin")
                MiniBadge(text: "Cümle")
                MiniBadge(text: "Av")
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

private struct MiniBadge: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(BlitzTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(BlitzTheme.primary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(BlitzTheme.primary.opacity(0.18), lineWidth: 1)
            }
    }
}

private struct ModeCard: View {
    var mode: BlitzMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer(minLength: 0)

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

            Spacer(minLength: 0)

            HStack {
                Text("Başla")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(glowColor)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(glowColor)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
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

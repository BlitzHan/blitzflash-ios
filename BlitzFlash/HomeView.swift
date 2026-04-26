import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words
    @EnvironmentObject private var monetization: MonetizationStore
    @State private var isShowingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BrandHeader()

                    premiumStatusCard

                    AdSlotView(placement: "Ana sayfa")

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingPaywall = true
                    } label: {
                        Image(systemName: monetization.isPremium ? "crown.fill" : "crown")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BlitzTheme.accent)
                    }
                    .accessibilityLabel("BlitzFlash Plus")
                }
            }
            .sheet(isPresented: $isShowingPaywall) {
                PremiumPaywallView()
            }
        }
    }

    private var premiumStatusCard: some View {
        Button {
            isShowingPaywall = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(BlitzTheme.accent.opacity(0.18))
                        .frame(width: 42, height: 42)

                    Image(systemName: monetization.isPremium ? "crown.fill" : "crown")
                        .font(.headline.weight(.black))
                        .foregroundStyle(BlitzTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(monetization.isPremium ? "Plus aktif" : "BlitzFlash Plus")
                        .font(.headline.weight(.black))
                        .foregroundStyle(BlitzTheme.ink)

                    Text(monetization.isPremium ? "Reklamsız kullanım açık." : "Reklamsız kullanım için yükselt.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(BlitzTheme.accent)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BlitzTheme.cardGradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BlitzTheme.accent.opacity(0.2), lineWidth: 1)
                    }
            )
        }
        .buttonStyle(.plain)
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
            WordHuntView(words: words)
        }
    }
}

private struct BrandHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                BlitzLogoMark(size: 64, cornerRadius: 16)
                    .shadow(color: BlitzTheme.accent.opacity(0.3), radius: 18, x: 0, y: 0)

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

                    Text("Kendi ritminde öğren, modunu seç ve başla.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
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

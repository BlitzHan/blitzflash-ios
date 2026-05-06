import SwiftUI

struct HomeView: View {
    private let words = VocabularyData.words
    @EnvironmentObject private var monetization: MonetizationStore
    @AppStorage("learningLanguage") private var learningLanguageRaw = LearningLanguage.english.rawValue
    @State private var isShowingPaywall = false
    @State private var isShowingSettings = false

    private var learningLanguage: LearningLanguage {
        LearningLanguage(rawValue: learningLanguageRaw) ?? .english
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BrandHeader()

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

                    AdSlotView(placement: "Ana sayfa")

                    VStack(spacing: 12) {
                        languageStatusCard
                        premiumStatusCard
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BlitzTheme.primary)
                    }
                    .accessibilityLabel("Ayarlar")
                }

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
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    private var languageStatusCard: some View {
        Button {
            isShowingSettings = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(BlitzTheme.primary.opacity(0.18))
                        .frame(width: 42, height: 42)

                    Text(learningLanguage.shortCode)
                        .font(.headline.weight(.black))
                        .foregroundStyle(BlitzTheme.primaryLight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Öğrenilen dil")
                        .font(.headline.weight(.black))
                        .foregroundStyle(BlitzTheme.ink)

                    Text("\(learningLanguage.title) - Türkçe")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(BlitzTheme.primary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BlitzTheme.cardGradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BlitzTheme.primary.opacity(0.2), lineWidth: 1)
                    }
            )
        }
        .buttonStyle(.plain)
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
            FreeStudyView(words: words.shuffled(), learningLanguage: learningLanguage)
        case .typing:
            TypingModeView(words: words.shuffled(), learningLanguage: learningLanguage)
        case .sentence:
            SentenceModeView(words: words.shuffled(), learningLanguage: learningLanguage)
        case .hunt:
            WordHuntView(words: words, learningLanguage: learningLanguage)
        }
    }
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("learningLanguage") private var learningLanguageRaw = LearningLanguage.english.rawValue

    private var selectedLanguage: LearningLanguage {
        LearningLanguage(rawValue: learningLanguageRaw) ?? .english
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ayarlar")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)

                        Text("BlitzFlash'te hangi dili Türkçe ile çalışacağını seç.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BlitzTheme.muted)
                    }

                    VStack(spacing: 12) {
                        ForEach(LearningLanguage.allCases) { language in
                            Button {
                                learningLanguageRaw = language.rawValue
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(language == selectedLanguage ? BlitzTheme.primary.opacity(0.24) : BlitzTheme.surfaceLight)
                                            .frame(width: 48, height: 48)

                                        Text(language.shortCode)
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(language == selectedLanguage ? BlitzTheme.primaryLight : BlitzTheme.muted)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(language.title)
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(BlitzTheme.ink)

                                        Text("\(language.nativeTitle) - Türkçe kelime çalışması")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(BlitzTheme.muted)
                                    }

                                    Spacer()

                                    Image(systemName: language == selectedLanguage ? "checkmark.circle.fill" : "circle")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(language == selectedLanguage ? BlitzTheme.success : BlitzTheme.dim)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(BlitzTheme.cardGradient)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke((language == selectedLanguage ? BlitzTheme.primary : BlitzTheme.primary.opacity(0.12)), lineWidth: 1)
                                        }
                                )
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(BlitzTheme.accent)
                }
            }
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

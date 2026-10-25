import SwiftUI

struct HomeView: View {
    @Environment(MonetizationStore.self) private var monetization
    @Environment(\.blitzLayout) private var layout
    @AppStorage("learningLanguage") private var learningLanguage = LearningLanguage.english
    @State private var path: [BlitzMode] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if layout.isSplit {
                    // Duo iç ekranı: bir bölmede marka, dil ve günlük hak; diğerinde dört mod
                    // (yatayda sağda, dikte/yarı açıkta alt yarıda, parmağın altında).
                    AdaptiveSplit(spacing: 20) {
                        BrandHeader(compact: false)
                        Picker("Dil", selection: $learningLanguage) {
                            ForEach(LearningLanguage.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        DailyAllowanceCard()
                        WordOfTheDayCard(language: learningLanguage)
                        Spacer(minLength: 0)
                    } secondary: {
                        modeGrid(fillsHeight: true, isLarge: true)
                    }
                    .padding(24)
                } else if layout.hasSideRail {
                    // Duo dış ekranı: günlük hak sağ şeritte; dört mod kalan alanı boydan boya doldurur.
                    VStack(alignment: .leading, spacing: 14) {
                        BrandHeader(compact: true)
                        modeGrid(fillsHeight: true, isLarge: false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .sideRail(layout) {
                        if !monetization.isPremium { RailAllowance() }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: layout.isShort ? 14 : 22) {
                            BrandHeader(compact: layout.isShort)
                            DailyAllowanceCard()
                            if layout.isShort {
                                // Duo dış ekranı: dört mod kaydırmadan sığsın diye 2×2.
                                modeGrid(fillsHeight: false, isLarge: false)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(BlitzMode.allCases) { mode in
                                        NavigationLink(value: mode) { ModeRow(mode: mode) }
                                            .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, layout.isShort ? 16 : 20)
                        .padding(.vertical, layout.isShort ? 8 : 18)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .blitzScreen()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !layout.isSplit {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Picker("Çalışılan dil", selection: $learningLanguage) {
                                ForEach(LearningLanguage.allCases) { language in
                                    Text("\(language.title) (\(language.nativeTitle))").tag(language)
                                }
                            }
                        } label: {
                            Label(learningLanguage.shortCode, systemImage: "globe")
                                .labelStyle(.titleAndIcon)
                        }
                        .accessibilityLabel("Çalışılan dil: \(learningLanguage.title)")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("BlitzFlash Plus", systemImage: monetization.isPremium ? "crown.fill" : "crown") {
                        monetization.isPaywallPresented = true
                    }
                    .tint(BlitzTheme.accent)
                }
            }
            .navigationDestination(for: BlitzMode.self) { mode in
                destination(for: mode)
            }
        }
        #if DEBUG
        // Ekran görüntüsü ve test için: `-openMode typing` doğrudan o modu açar.
        .onAppear {
            if path.isEmpty, let mode = UserDefaults.standard.string(forKey: "openMode").flatMap(BlitzMode.init) {
                path = [mode]
            }
        }
        #endif
    }

    private func modeGrid(fillsHeight: Bool, isLarge: Bool) -> some View {
        VStack(spacing: 12) {
            ForEach([[BlitzMode.free, .typing], [BlitzMode.sentence, .hunt]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row) { mode in
                        NavigationLink(value: mode) { ModeTile(mode: mode, isLarge: isLarge, fillsHeight: fillsHeight) }
                            .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// Hedef ekran yalnızca açılınca oluşturulur (eskiden ana sayfa her çizimde dört modu
    /// ve 889 kelimelik karıştırmayı baştan hazırlıyordu).
    @ViewBuilder
    private func destination(for mode: BlitzMode) -> some View {
        let words = learningLanguage.words.shuffled()
        switch mode {
        case .free: FreeStudyView(words: words, learningLanguage: learningLanguage)
        case .typing: TypingModeView(words: words, learningLanguage: learningLanguage)
        case .sentence: SentenceModeView(words: words, learningLanguage: learningLanguage)
        case .hunt: WordHuntView(words: words, learningLanguage: learningLanguage)
        }
    }
}

private struct BrandHeader: View {
    var compact: Bool

    var body: some View {
        HStack(spacing: 14) {
            BlitzLogoMark(size: compact ? 44 : 56, cornerRadius: compact ? 11 : 14)

            VStack(alignment: .leading, spacing: 4) {
                Text("BlitzFlash")
                    .font(.system(size: compact ? 26 : 34, weight: .bold, design: .rounded))
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !compact {
                    Text("Kendi ritminde öğren, modunu seç ve başla.")
                        .font(.subheadline)
                        .foregroundStyle(BlitzTheme.muted)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
    }
}

/// Ücretsiz kullanıcıya bugün kalan hakkı, Plus kullanıcısına durumunu gösterir.
private struct DailyAllowanceCard: View {
    @Environment(MonetizationStore.self) private var monetization

    var body: some View {
        Button {
            monetization.isPaywallPresented = true
        } label: {
            HStack(spacing: 14) {
                if monetization.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(BlitzTheme.accent)
                        .frame(width: 48, height: 48)
                        .background(BlitzTheme.accent.opacity(0.14), in: .circle)
                } else {
                    Gauge(value: Double(monetization.remainingToday), in: 0...Double(MonetizationStore.freeDailyLimit)) {
                        EmptyView()
                    } currentValueLabel: {
                        Text("\(monetization.remainingToday)")
                            .font(.headline.monospacedDigit())
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(monetization.remainingToday > 5 ? BlitzTheme.primary : BlitzTheme.danger)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(monetization.isPremium ? "Plus aktif" : "Bugünkü hakkın")
                        .font(.headline)
                        .foregroundStyle(BlitzTheme.ink)
                    Text(monetization.isPremium
                         ? "Sınırsız çalışabilirsin."
                         : "\(MonetizationStore.freeDailyLimit) sorudan \(monetization.remainingToday) kaldı. Plus ile sınırsız.")
                        .font(.subheadline)
                        .foregroundStyle(BlitzTheme.muted)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                if !monetization.isPremium {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.dim)
                }
            }
            .padding(14)
            .background(BlitzTheme.surface, in: .rect(cornerRadius: 16))
            .shadow(color: BlitzTheme.cardShadow, radius: 10, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(monetization.isPremium)
    }
}

/// Duo dış ekranı sağ şeridi: bugün kalan hak. Dokununca Plus sayfası açılır.
private struct RailAllowance: View {
    @Environment(MonetizationStore.self) private var monetization

    var body: some View {
        Button {
            monetization.isPaywallPresented = true
        } label: {
            VStack(spacing: 4) {
                Gauge(value: Double(monetization.remainingToday), in: 0...Double(MonetizationStore.freeDailyLimit)) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(monetization.remainingToday)")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(monetization.remainingToday > 5 ? BlitzTheme.primary : BlitzTheme.danger)
                .scaleEffect(0.8)
                .frame(width: 48, height: 48)

                Text("hak")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(BlitzTheme.muted)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Bugünkü hakkın: \(monetization.remainingToday)")
    }
}

/// Duo iç ekranı sol bölmesi: her gün değişen bir kelime.
private struct WordOfTheDayCard: View {
    var language: LearningLanguage

    private var word: VocabularyWord? {
        let words = language.words
        guard !words.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        return words[day % words.count]
    }

    var body: some View {
        if let word {
            VStack(alignment: .leading, spacing: 8) {
                Label("Günün kelimesi", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BlitzTheme.accent)

                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(word.targetTerm(for: language))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(BlitzTheme.ink)
                    if let pronunciation = word.targetPronunciation(for: language) {
                        Text("[ \(pronunciation) ]")
                            .font(.callout.italic())
                            .foregroundStyle(BlitzTheme.secondary)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                Text(word.turkish)
                    .font(.headline)
                    .foregroundStyle(BlitzTheme.muted)

                if let sentence = word.targetSentence(for: language) {
                    Text(sentence)
                        .font(.subheadline)
                        .foregroundStyle(BlitzTheme.muted)
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BlitzTheme.surface, in: .rect(cornerRadius: 16))
            .shadow(color: BlitzTheme.cardShadow, radius: 10, x: 0, y: 3)
        }
    }
}

private struct ModeIcon: View {
    var mode: BlitzMode
    var size: CGFloat

    var body: some View {
        Image(systemName: mode.icon)
            .font(size > 52 ? .title2.weight(.semibold) : .title3.weight(.semibold))
            .foregroundStyle(mode.tint)
            .frame(width: size, height: size)
            .background(mode.tint.opacity(0.14), in: .rect(cornerRadius: size * 0.24))
    }
}

/// Normal iPhone: tam genişlik satır.
private struct ModeRow: View {
    var mode: BlitzMode

    var body: some View {
        HStack(spacing: 14) {
            ModeIcon(mode: mode, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(BlitzTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(mode.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BlitzTheme.muted)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BlitzTheme.dim)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .background(BlitzTheme.surface, in: .rect(cornerRadius: 16))
        .shadow(color: BlitzTheme.cardShadow, radius: 10, x: 0, y: 3)
    }
}

/// Duo ekranları: 2×2 kare kart. İç ekranda sağ bölmeyi boydan boya doldurur.
private struct ModeTile: View {
    var mode: BlitzMode
    var isLarge: Bool
    var fillsHeight = false

    var body: some View {
        VStack(alignment: .leading, spacing: isLarge ? 10 : 6) {
            ModeIcon(mode: mode, size: isLarge ? 60 : 42)

            Spacer(minLength: 0)

            Text(mode.title)
                .font(isLarge ? .title3.weight(.bold) : .headline)
                .foregroundStyle(BlitzTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(mode.subtitle)
                .font(isLarge ? .subheadline : .caption)
                .foregroundStyle(BlitzTheme.muted)
                .lineLimit(isLarge ? 3 : 2, reservesSpace: true)
        }
        .padding(isLarge ? 20 : 14)
        .frame(maxWidth: .infinity, minHeight: isLarge ? 160 : 132, maxHeight: fillsHeight ? .infinity : nil, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(BlitzTheme.surface)
                .overlay(alignment: .topTrailing) {
                    // Modun renginde hafif köşe parıltısı.
                    Circle()
                        .fill(mode.tint.opacity(0.16))
                        .frame(width: isLarge ? 180 : 110)
                        .blur(radius: 40)
                        .offset(x: 40, y: -40)
                }
                .clipShape(.rect(cornerRadius: 20))
        }
        .shadow(color: BlitzTheme.cardShadow, radius: 10, x: 0, y: 3)
        .contentShape(.rect(cornerRadius: 20))
    }
}

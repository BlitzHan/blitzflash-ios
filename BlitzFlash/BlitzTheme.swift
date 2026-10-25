import SwiftUI

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum BlitzTheme {
    // Vurgu renkleri — açık/koyu moda uyumlu
    static let primary = Color(
        light: Color(red: 0.15, green: 0.42, blue: 0.96),
        dark: Color(red: 0.42, green: 0.6, blue: 1.0)
    )
    static let secondary = Color(
        light: Color(red: 0.48, green: 0.32, blue: 0.93),
        dark: Color(red: 0.65, green: 0.54, blue: 1.0)
    )
    static let accent = Color(
        light: Color(red: 0.95, green: 0.55, blue: 0.08),
        dark: Color(red: 1.0, green: 0.66, blue: 0.25)
    )
    static let success = Color(
        light: Color(red: 0.13, green: 0.62, blue: 0.33),
        dark: Color(red: 0.3, green: 0.82, blue: 0.5)
    )
    static let danger = Color(
        light: Color(red: 0.88, green: 0.22, blue: 0.24),
        dark: Color(red: 1.0, green: 0.42, blue: 0.42)
    )

    // Yüzeyler — sistem semantik renkleri
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
    static let surfaceLight = Color(.tertiarySystemGroupedBackground)

    // Metin
    static let ink = Color.primary
    static let muted = Color.secondary
    static let dim = Color(.tertiaryLabel)

    // Kart gölgesi — açık modda yumuşak, koyu modda görünmez denecek kadar hafif
    static let cardShadow = Color.black.opacity(0.07)
}

struct BlitzBackground: View {
    var body: some View {
        BlitzTheme.background
            .ignoresSafeArea()
    }
}

struct BlitzCard<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(BlitzTheme.surface)
            )
            .shadow(color: BlitzTheme.cardShadow, radius: 12, x: 0, y: 4)
    }
}

extension BlitzMode {
    var tint: Color {
        switch self {
        case .free: BlitzTheme.primary
        case .typing: BlitzTheme.secondary
        case .sentence: BlitzTheme.success
        case .hunt: BlitzTheme.accent
        }
    }
}

/// Uygulamadaki tüm tam genişlik düğmeler. iOS 26+ Liquid Glass, öncesinde düz dolgu.
struct BlitzButtonLabel: View {
    var title: String
    var icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

extension View {
    @ViewBuilder
    func blitzButton(tint: Color = BlitzTheme.primary, prominent: Bool = true) -> some View {
        if #available(iOS 26, *) {
            if prominent {
                buttonStyle(.glassProminent).tint(tint).controlSize(.large)
            } else {
                buttonStyle(.glass).tint(tint).controlSize(.large)
            }
        } else {
            buttonStyle(.borderedProminent)
                .tint(prominent ? tint : tint.opacity(0.14))
                .foregroundStyle(prominent ? Color.white : tint)
                .controlSize(.large)
                .buttonBorderShape(.roundedRectangle(radius: 14))
        }
    }

    func blitzScreen() -> some View {
        background(BlitzBackground())
            .tint(BlitzTheme.primary)
    }

    /// Cevap kutusu görünümü (Yazarak Tahmin, Kelime Avı).
    func blitzAnswerField() -> some View {
        textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .padding(14)
            .foregroundStyle(BlitzTheme.ink)
            .background(BlitzTheme.surface, in: .rect(cornerRadius: 14))
            .shadow(color: BlitzTheme.cardShadow, radius: 6, x: 0, y: 2)
    }
}

struct StatPill: View {
    var title: String
    var value: Int
    var color: Color

    @Environment(\.isInSideRail) private var isInSideRail

    var body: some View {
        let label = VStack(spacing: isInSideRail ? 1 : 3) {
            Text("\(value)")
                .font(isInSideRail ? .subheadline.weight(.bold) : .headline.weight(.bold))
                .foregroundStyle(color)
                .contentTransition(.numericText(value: Double(value)))
                .animation(.snappy, value: value)

            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(BlitzTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .monospacedDigit()

        if isInSideRail {
            label
                .frame(width: 52)
                .accessibilityElement(children: .combine)
        } else {
            label
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(BlitzTheme.surface, in: .rect(cornerRadius: 12))
                .shadow(color: BlitzTheme.cardShadow, radius: 6, x: 0, y: 2)
        }
    }
}

/// Sayaç satırı: normalde yan yana, yan şeritte alt alta.
struct StatGroup<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\.isInSideRail) private var isInSideRail

    var body: some View {
        if isInSideRail {
            VStack(spacing: 12) { content }
                .padding(.vertical, 8)
        } else {
            HStack { content }
        }
    }
}

/// Oyun sonu kartı (Yazarak Tahmin, Kelime Avı).
struct ResultCard: View {
    var title: String
    var score: Int
    var detail: String
    var finishedAt: Date
    var onReplay: () -> Void

    var body: some View {
        BlitzCard {
            VStack(spacing: 14) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(BlitzTheme.accent)
                    .symbolEffect(.bounce, value: finishedAt)

                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BlitzTheme.ink)

                Text(finishedAt.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(BlitzTheme.muted)

                Text("\(score) puan")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(score >= 0 ? BlitzTheme.success : BlitzTheme.danger)

                Text(detail)
                    .font(.headline)
                    .foregroundStyle(BlitzTheme.primary)

                Button(action: onReplay) {
                    BlitzButtonLabel(title: "Tekrar Oyna", icon: "arrow.clockwise")
                }
                .blitzButton(tint: BlitzTheme.accent)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// Kısa bekleme; görünüm kapanınca ya da yeni bekleme başlayınca iptal olur.
@MainActor
final class Delay {
    private var task: Task<Void, Never>?

    func run(after seconds: Double, _ action: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: .seconds(seconds))
            if !Task.isCancelled { action() }
        }
    }

    func cancel() { task?.cancel() }
}

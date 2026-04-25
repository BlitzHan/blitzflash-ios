import SwiftUI

enum BlitzTheme {
    static let primary = Color(red: 0.0, green: 0.94, blue: 1.0)
    static let primaryDark = Color(red: 0.0, green: 0.62, blue: 0.7)
    static let primaryLight = Color(red: 0.4, green: 0.97, blue: 1.0)
    static let secondary = Color(red: 1.0, green: 0.18, blue: 0.49)
    static let accent = Color(red: 1.0, green: 0.72, blue: 0.0)
    static let background = Color(red: 0.03, green: 0.03, blue: 0.06)
    static let surface = Color(red: 0.06, green: 0.06, blue: 0.12)
    static let surfaceLight = Color(red: 0.1, green: 0.1, blue: 0.19)
    static let ink = Color(red: 0.93, green: 0.94, blue: 0.96)
    static let muted = Color(red: 0.55, green: 0.56, blue: 0.66)
    static let dim = Color(red: 0.33, green: 0.35, blue: 0.45)
    static let success = Color(red: 0.0, green: 0.9, blue: 0.46)
    static let danger = Color(red: 1.0, green: 0.24, blue: 0.35)
    static let warm = accent

    static let cardGradient = LinearGradient(
        colors: [surface, surfaceLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cyanMagenta = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct BlitzBackground: View {
    var body: some View {
        ZStack {
            BlitzTheme.background

            GridPattern()
                .stroke(BlitzTheme.primary.opacity(0.055), lineWidth: 1)

            LinearGradient(
                colors: [
                    BlitzTheme.primary.opacity(0.22),
                    .clear,
                    BlitzTheme.secondary.opacity(0.16),
                    BlitzTheme.accent.opacity(0.08)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .blur(radius: 28)

            VStack {
                HStack {
                    Spacer()
                    LightningGlyph(size: 150)
                        .foregroundStyle(BlitzTheme.primary.opacity(0.08))
                        .rotationEffect(.degrees(12))
                        .padding(.trailing, -22)
                }

                Spacer()

                HStack {
                    LightningGlyph(size: 110)
                        .foregroundStyle(BlitzTheme.secondary.opacity(0.08))
                        .rotationEffect(.degrees(-18))
                        .padding(.leading, -16)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 42

        var x: CGFloat = 0
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += spacing
        }

        var y: CGFloat = 0
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }

        return path
    }
}

struct LightningGlyph: View {
    var size: CGFloat = 38

    var body: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: size, weight: .black))
            .shadow(color: BlitzTheme.primary.opacity(0.35), radius: 18, x: 0, y: 0)
    }
}

struct BlitzCard<Content: View>: View {
    var glow: Color
    var content: Content

    init(glow: Color = BlitzTheme.primary, @ViewBuilder content: () -> Content) {
        self.glow = glow
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BlitzTheme.cardGradient)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [.clear, glow.opacity(0.85), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 2)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(glow.opacity(0.16), lineWidth: 1)
                    }
            )
            .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 16)
            .shadow(color: glow.opacity(0.12), radius: 28, x: 0, y: 0)
    }
}

struct SectionHeader: View {
    var title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(BlitzTheme.ink)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BlitzTheme.primary)
            }
        }
    }
}

struct BlitzProminentButton: ButtonStyle {
    var tint: Color = BlitzTheme.primary
    var darkText = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(darkText ? BlitzTheme.background : .white)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: tint.opacity(configuration.isPressed ? 0.18 : 0.34), radius: configuration.isPressed ? 8 : 18, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension View {
    func blitzScreen() -> some View {
        background(BlitzBackground())
            .toolbarBackground(BlitzTheme.background.opacity(0.92), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(BlitzTheme.primary)
    }
}

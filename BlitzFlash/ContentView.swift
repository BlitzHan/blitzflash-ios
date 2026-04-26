import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            HomeView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .tint(BlitzTheme.primary)
        .task {
            try? await Task.sleep(for: .seconds(1.35))
            withAnimation(.easeInOut(duration: 0.35)) {
                showSplash = false
            }
        }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            BlitzBackground()

            VStack(spacing: 18) {
                BlitzLogoMark(size: 126, cornerRadius: 28)
                    .shadow(color: BlitzTheme.accent.opacity(0.34), radius: 30, x: 0, y: 0)

                VStack(spacing: 6) {
                    Text("BlitzFlash")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(BlitzTheme.ink)

                    Text("Kelimeyi yakala.")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BlitzTheme.accent)
                }
            }
            .padding(.horizontal, 28)
        }
    }
}

struct BlitzLogoMark: View {
    var size: CGFloat
    var cornerRadius: CGFloat = 16

    var body: some View {
        Image("BlitzLogo")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [BlitzTheme.accent.opacity(0.9), BlitzTheme.primary.opacity(0.38)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

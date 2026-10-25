import SwiftUI

struct ContentView: View {
    @Environment(MonetizationStore.self) private var monetization
    @State private var showSplash = true

    var body: some View {
        @Bindable var monetization = monetization

        ZStack {
            GeometryReader { proxy in
                HomeView()
                    .environment(\.blitzLayout, BlitzLayout(size: proxy.size))
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .tint(BlitzTheme.primary)
        .sheet(isPresented: $monetization.isPaywallPresented) {
            PremiumPaywallView()
        }
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

            VStack(spacing: 20) {
                BlitzLogoMark(size: 110, cornerRadius: 26)

                VStack(spacing: 6) {
                    Text("BlitzFlash")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(BlitzTheme.ink)

                    Text("Kelimeyi yakala.")
                        .font(.headline)
                        .foregroundStyle(BlitzTheme.muted)
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
            .shadow(color: BlitzTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}

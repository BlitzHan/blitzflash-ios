import SwiftUI

enum BlitzTheme {
    static let primary = Color(red: 0.18, green: 0.43, blue: 0.96)
    static let secondary = Color(red: 0.08, green: 0.68, blue: 0.66)
    static let ink = Color(red: 0.08, green: 0.1, blue: 0.16)
    static let muted = Color(red: 0.42, green: 0.45, blue: 0.52)
    static let surface = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let warm = Color(red: 0.96, green: 0.62, blue: 0.25)
}

struct BlitzCard<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
    }
}

struct SectionHeader: View {
    var title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(BlitzTheme.ink)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

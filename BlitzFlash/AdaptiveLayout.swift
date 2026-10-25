import SwiftUI

/// Ekran sınıfı. Kökte (`ContentView`) bir kez ölçülüp ortam değeri olarak yayılır.
/// - `isWide`: iPhone Duo iç ekranı yatayken (~950×626pt). Katlanma çizgisi o zaman dikeydir;
///   iç ekran dik tutulunca çizgi yatay olur ve tek sütun daha doğal kalır. Normal iPhone'lar
///   dikey kilitli olduğundan (en geniş 440pt) bu eşiğe ulaşamaz.
/// - `isShort`: Duo dış ekranı (~585pt) ve iPhone SE gibi kısa ekranlar.
struct BlitzLayout: Equatable {
    var isWide = false
    var isShort = false

    init(size: CGSize = .zero) {
        isWide = UIDevice.current.userInterfaceIdiom == .phone && size.width >= 560 && size.width > size.height
        isShort = !isWide && size.height > 0 && size.height < 660
    }
}

extension EnvironmentValues {
    @Entry var blitzLayout = BlitzLayout()
}

/// Duo iç ekranında iki eşit bölme, aradaki boşluk katlanma çizgisinin üstünde durur;
/// böylece hiçbir dokunma hedefi çizgiye denk gelmez. Diğer ekranlarda alt alta dizer.
struct AdaptiveSplit<Primary: View, Secondary: View>: View {
    var spacing: CGFloat = 16
    @ViewBuilder var primary: Primary
    @ViewBuilder var secondary: Secondary

    @Environment(\.blitzLayout) private var layout
    @State private var hingeX: CGFloat?
    private let hingeGap: CGFloat = 40

    var body: some View {
        if layout.isWide {
            GeometryReader { proxy in
                let hinge = min(max(hingeX ?? proxy.size.width / 2, hingeGap), proxy.size.width - hingeGap)
                HStack(spacing: hingeGap) {
                    VStack(spacing: spacing) { primary }
                        .frame(width: hinge - hingeGap / 2)
                        .frame(maxHeight: .infinity)
                    VStack(spacing: spacing) { secondary }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            // Yan sekme çubuğu ve güvenli alanlar içeriği kaydırır; çizgi ekran koordinatından okunur.
            .background(ScreenCenterReader(centerX: $hingeX))
        } else {
            VStack(spacing: spacing) {
                primary
                secondary
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

/// Bağlı olduğu görünümün kendi koordinatlarında ekranın dikey orta çizgisinin x konumunu bildirir.
private struct ScreenCenterReader: UIViewRepresentable {
    @Binding var centerX: CGFloat?

    func makeUIView(context: Context) -> ReaderView {
        let view = ReaderView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: ReaderView, context: Context) {
        view.onChange = { x in
            if centerX != x { centerX = x }
        }
    }

    final class ReaderView: UIView {
        var onChange: ((CGFloat) -> Void)?

        override func layoutSubviews() {
            super.layoutSubviews()
            report()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            report()
        }

        private func report() {
            guard let screen = window?.windowScene?.screen else { return }
            let x = screen.bounds.width / 2 - convert(bounds, to: screen.coordinateSpace).minX
            // Yerleşim sırasında SwiftUI durumunu değiştirmemek için bir sonraki tura ertele.
            DispatchQueue.main.async { [weak self] in self?.onChange?(x) }
        }
    }
}

/// Yön kilidi ekran boyutuna göre belirlenir. Info.plist iPhone'da yatayı da açar
/// (yoksa iOS, Duo'nun yatay doğan iç ekranında uygulamayı iki yanı siyah bir uyumluluk
/// penceresinde açar); normal iPhone'larda ve Duo dış ekranında burada dikeye kilitlenir.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let bounds = window?.windowScene?.screen.bounds else { return .portrait }
        return min(bounds.width, bounds.height) >= 600 ? .allButUpsideDown : .portrait
    }
}

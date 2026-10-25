import SwiftUI

/// Ekran sınıfı. Kökte (`ContentView`) bir kez ölçülüp ortam değeri olarak yayılır.
/// - `isWide`: iPhone Duo iç ekranı yatayken (~950×626pt). Katlanma çizgisi dikeydir: bölmeler yan yana.
/// - `isTall`: iç ekran dik tutulunca (~626×950pt). Çizgi yataydır; yarı açık "dizüstü" duruşunda
///   üst yarı okunur, alt yarıya dokunulur. Bölmeler üst üste, ortadaki kelime çizgiye düşmez.
///   Normal iPhone'lar dikey kilitli olduğundan (en geniş 440pt) bu iki eşiğe ulaşamaz.
/// - `isShort`: Duo dış ekranı (~585pt) ve iPhone SE gibi kısa ekranlar.
/// - `hasSideRail`: iOS 27 Duo dış ekranında durum ve araç çubuğunu sağda dikey bir şeride alır
///   (~90pt). Kamera, saat ve araç düğmeleri şeridin üstündedir, altı boş kalır; sayaçlar ve
///   günlük hak oraya (`sideRail`) taşınır, içerik alanı karta kalır. Araç çubuğuna fazladan öğe
///   eklemek işe yaramaz: şerit sığmayanı üstteki ayrı bir sıraya taşır.
/// - `isHalfOpen`: menteşe yarı açık (iOS 27.1+); bölmeler arası boşluk büyür.
struct BlitzLayout: Equatable {
    var isWide = false
    var isTall = false
    var isShort = false
    var sideRailWidth: CGFloat = 0
    var isHalfOpen = false

    var hasSideRail: Bool { sideRailWidth > 0 }

    /// İki bölmeli düzen (yan yana ya da üst üste).
    var isSplit: Bool { isWide || isTall }

    init(size: CGSize = .zero, safeArea: EdgeInsets = EdgeInsets(), isHalfOpen: Bool = false) {
        let isFoldable = UIDevice.current.userInterfaceIdiom == .phone && min(size.width, size.height) >= 560
        isWide = isFoldable && size.width > size.height
        isTall = isFoldable && size.height > size.width
        isShort = !isSplit && size.height > 0 && size.height < 660
        sideRailWidth = !isSplit && safeArea.trailing >= 40 ? safeArea.trailing : 0
        self.isHalfOpen = isSplit && isHalfOpen
    }
}

extension EnvironmentValues {
    @Entry var blitzLayout = BlitzLayout()
    /// Görünüm araç çubuğunun yan şeridinde mi çiziliyor (`StatPill`, `StatGroup` dikey ve sade olur).
    @Entry var isInSideRail = false
}

extension View {
    /// Yan şerit varsa içeriği şeridin boş alt kısmına yerleştirir. Güvenli alanın sağ kenarına
    /// dayanan bir görünüme uygulanır; çağıran ekran o durumda kendi sayaç satırını göstermez.
    func sideRail<Rail: View>(_ layout: BlitzLayout, @ViewBuilder content: () -> Rail) -> some View {
        let rail = content()
        return overlay(alignment: .bottomTrailing) {
            if layout.hasSideRail {
                rail
                    .environment(\.isInSideRail, true)
                    .frame(width: layout.sideRailWidth)
                    .padding(.bottom, 12)
                    .offset(x: layout.sideRailWidth)
            }
        }
    }
}

extension View {
    /// Menteşe yarı açık mı (iOS 27.1 `onHingeChange`). Eski sürümlerde hep `false`.
    func readsHalfOpenHinge(_ isHalfOpen: Binding<Bool>) -> some View {
        modifier(HingeReader(isHalfOpen: isHalfOpen))
    }
}

private struct HingeReader: ViewModifier {
    @Binding var isHalfOpen: Bool

    func body(content: Content) -> some View {
        if #available(iOS 27.1, *) {
            content.onHingeChange { _, context in
                withAnimation(.smooth) { isHalfOpen = context.hinge?.status == .partiallyOpen }
            }
        } else {
            content
        }
    }
}

/// Duo iç ekranında iki bölme; aradaki boşluk katlanma çizgisinin üstünde durur, böylece
/// hiçbir metin ya da dokunma hedefi çizgiye denk gelmez. Yatayda yan yana, dikte üst üste
/// (birincil üstte: okunacak kart; ikincil altta: düğmeler). Diğer ekranlarda alt alta dizer.
struct AdaptiveSplit<Primary: View, Secondary: View>: View {
    var spacing: CGFloat = 16
    @ViewBuilder var primary: Primary
    @ViewBuilder var secondary: Secondary

    @Environment(\.blitzLayout) private var layout
    @State private var screenCenter: CGPoint?

    /// Yarı açıkken çizginin iki yanı eğik durur; daha geniş bırakılır.
    private var hingeGap: CGFloat { layout.isHalfOpen ? 64 : 40 }

    var body: some View {
        if layout.isWide {
            GeometryReader { proxy in
                let hinge = clamped(screenCenter?.x, in: proxy.size.width)
                HStack(spacing: hingeGap) {
                    VStack(spacing: spacing) { primary }
                        .frame(width: hinge - hingeGap / 2)
                        .frame(maxHeight: .infinity)
                    VStack(spacing: spacing) { secondary }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            // Yan şerit ve güvenli alanlar içeriği kaydırır; çizgi ekran koordinatından okunur.
            .background(ScreenCenterReader(center: $screenCenter))
        } else if layout.isTall {
            GeometryReader { proxy in
                let hinge = clamped(screenCenter?.y, in: proxy.size.height)
                VStack(spacing: hingeGap) {
                    VStack(spacing: spacing) { primary }
                        .frame(maxWidth: .infinity)
                        .frame(height: hinge - hingeGap / 2)
                    VStack(spacing: spacing) { secondary }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(ScreenCenterReader(center: $screenCenter))
            // Klavye alt yarıyı örter; düzen kaymaz, üst yarıdaki yazı alanı çizginin üstünde kalır.
            .ignoresSafeArea(.keyboard)
        } else {
            VStack(spacing: spacing) {
                primary
                secondary
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func clamped(_ value: CGFloat?, in length: CGFloat) -> CGFloat {
        min(max(value ?? length / 2, hingeGap), length - hingeGap)
    }
}

/// Bağlı olduğu görünümün kendi koordinatlarında ekranın orta noktasını (katlanma çizgisi) bildirir.
private struct ScreenCenterReader: UIViewRepresentable {
    @Binding var center: CGPoint?

    func makeUIView(context: Context) -> ReaderView {
        let view = ReaderView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: ReaderView, context: Context) {
        view.onChange = { point in
            if center != point { center = point }
        }
    }

    final class ReaderView: UIView {
        var onChange: ((CGPoint) -> Void)?

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
            let frame = convert(bounds, to: screen.coordinateSpace)
            let point = CGPoint(x: screen.bounds.midX - frame.minX, y: screen.bounds.midY - frame.minY)
            // Yerleşim sırasında SwiftUI durumunu değiştirmemek için bir sonraki tura ertele.
            DispatchQueue.main.async { [weak self] in self?.onChange?(point) }
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

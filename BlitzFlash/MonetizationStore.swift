import Combine
import StoreKit
import SwiftUI

@MainActor
final class MonetizationStore: ObservableObject {
    static let weeklyProductID = "com.blitzhanlabs.BlitzFlash.plus.weekly"
    static let monthlyProductID = "com.blitzhanlabs.BlitzFlash.plus.monthly"
    static let lifetimeProductID = "com.blitzhanlabs.BlitzFlash.premium.lifetime"
    static let legacyWeeklyProductID = "com.blitzhanlabs.BlitzFlash.premium.weekly"
    static let legacyMonthlyProductID = "com.blitzhanlabs.BlitzFlash.premium.monthly"
    static let legacyLifetimeProductID = "com.blitzhanlabs.BlitzFlash.plus.lifetime"
    static let adsEnabled = false

    static let productIDs = [
        weeklyProductID,
        monthlyProductID,
        lifetimeProductID,
        legacyWeeklyProductID,
        legacyMonthlyProductID,
        legacyLifetimeProductID
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published private(set) var didAttemptProductLoad = false

    private var transactionUpdatesTask: Task<Void, Never>?

    var isPremium: Bool {
        !purchasedProductIDs.isDisjoint(with: Self.productIDs)
    }

    var sortedProducts: [Product] {
        products.sorted { lhs, rhs in
            sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
        }
    }

    func start() {
        guard transactionUpdatesTask == nil else { return }
        transactionUpdatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refreshEntitlements()
            }
        }

        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        isLoading = true
        didAttemptProductLoad = true
        errorMessage = nil
        do {
            products = try await Product.products(for: Self.productIDs)
            if products.isEmpty {
                errorMessage = "Satın alma ürünleri App Store'dan alınamadı."
            }
        } catch {
            errorMessage = "Satın alma seçenekleri yüklenemedi."
        }
        isLoading = false
    }

    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = "Satın alma doğrulanamadı."
                    isLoading = false
                    return
                }
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                errorMessage = "Satın alma onay bekliyor."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Satın alma tamamlanamadı."
            }
        } catch {
            errorMessage = "Satın alma tamamlanamadı."
        }
        isLoading = false
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Satın almalar geri yüklenemedi."
        }
        isLoading = false
    }

    func refreshEntitlements() async {
        var activeProductIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil
            else {
                continue
            }
            activeProductIDs.insert(transaction.productID)
        }
        purchasedProductIDs = activeProductIDs
    }

    private func sortIndex(for productID: String) -> Int {
        switch productID {
        case Self.weeklyProductID, Self.legacyWeeklyProductID: 0
        case Self.monthlyProductID, Self.legacyMonthlyProductID: 1
        case Self.lifetimeProductID, Self.legacyLifetimeProductID: 2
        default: 99
        }
    }
}

struct AdSlotView: View {
    @EnvironmentObject private var monetization: MonetizationStore
    var placement: String

    var body: some View {
        if MonetizationStore.adsEnabled && !monetization.isPremium {
            HStack(spacing: 10) {
                Image(systemName: "bolt.horizontal.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(BlitzTheme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sponsorlu")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BlitzTheme.accent)

                    Text("BlitzFlash Plus ile reklamsız devam et")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(BlitzTheme.muted)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(BlitzTheme.surface.opacity(0.92))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(BlitzTheme.accent.opacity(0.22), lineWidth: 1)
                    }
            )
            .accessibilityLabel("\(placement) reklam alanı")
        }
    }
}

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var monetization: MonetizationStore
    @State private var isRedeemCodePresented = false

    private let fallbackPlans = [
        PremiumPlanPreview(title: "Haftalık Plus", subtitle: "Kısa süreli Plus erişimi", price: "₺24,99"),
        PremiumPlanPreview(title: "Aylık Plus", subtitle: "Düzenli çalışma için Plus erişimi", price: "₺89,99"),
        PremiumPlanPreview(title: "Ömür Boyu Plus", subtitle: "Tek ödeme, kalıcı Plus erişimi", price: "₺199,99")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        BlitzLogoMark(size: 64, cornerRadius: 16)

                        Text("BlitzFlash Plus")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)

                        Text("BlitzFlash'i destekle, Plus ayrıcalıklarını kullan ve modlar arasında kesintisiz ilerle.")
                            .font(.headline)
                            .foregroundStyle(BlitzTheme.muted)
                    }

                    BlitzCard(glow: BlitzTheme.accent) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Plus ile neler var?", systemImage: "crown.fill")
                                .font(.headline.weight(.black))
                                .foregroundStyle(BlitzTheme.ink)

                            benefitRow("BlitzFlash'in gelişimini destekle.")
                            benefitRow("Satın aldığın Plus erişimini tüm Apple cihazlarında geri yükle.")
                            benefitRow("Reklamlar aktif olduğunda reklamsız ve kesintisiz devam et.")
                            benefitRow("Yeni kelime setleri ve çalışma seçenekleri için hazır kal.")
                        }
                    }

                    if monetization.sortedProducts.isEmpty {
                        VStack(spacing: 10) {
                            ForEach(fallbackPlans) { plan in
                                unavailablePlanRow(plan)
                            }
                        }

                        Text(monetization.isLoading ? "Satın alma seçenekleri yükleniyor..." : "Satın alma seçenekleri App Store'dan alınamadı. Paketleri satın alınabilir hale getirmek için App Store Connect ürünlerinin bu sürüme ekli ve incelemeye hazır olması gerekir.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BlitzTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            Task {
                                await monetization.loadProducts()
                                await monetization.refreshEntitlements()
                            }
                        } label: {
                            Label("Tekrar Dene", systemImage: "arrow.clockwise")
                                .font(.headline.weight(.bold))
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BlitzOutlineButton(tint: BlitzTheme.accent))
                        .disabled(monetization.isLoading)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(monetization.sortedProducts, id: \.id) { product in
                                productPlanButton(product)
                            }
                        }
                    }

                    if let errorMessage = monetization.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BlitzTheme.danger)
                    }

                    Button {
                        Task {
                            await monetization.restorePurchases()
                        }
                    } label: {
                        Label("Satın Almaları Geri Yükle", systemImage: "arrow.clockwise")
                            .font(.headline.weight(.bold))
                            .padding(.vertical, 13)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BlitzProminentButton(tint: BlitzTheme.primary))

                    Button {
                        isRedeemCodePresented = true
                    } label: {
                        Label("Kod Kullan", systemImage: "gift.fill")
                            .font(.headline.weight(.bold))
                            .padding(.vertical, 13)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BlitzOutlineButton(tint: BlitzTheme.accent))

                    Text("Abonelikler Apple hesabın üzerinden yönetilir. Ömür boyu lisans tek seferlik satın almadır. Hediye kodları App Store Connect üzerinden oluşturulur.")
                        .font(.caption)
                        .foregroundStyle(BlitzTheme.muted)
                }
                .padding(20)
            }
            .blitzScreen()
            .navigationTitle("Plus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(BlitzTheme.primary)
                }
            }
            .task {
                await monetization.loadProducts()
                await monetization.refreshEntitlements()
            }
            .offerCodeRedemption(isPresented: $isRedeemCodePresented) { result in
                Task {
                    await monetization.refreshEntitlements()
                    if case .failure = result {
                        monetization.errorMessage = "Kod kullanma ekranı açılamadı."
                    }
                }
            }
        }
    }

    private func title(for product: Product) -> String {
        switch product.id {
        case MonetizationStore.weeklyProductID, MonetizationStore.legacyWeeklyProductID: "Haftalık Plus"
        case MonetizationStore.monthlyProductID, MonetizationStore.legacyMonthlyProductID: "Aylık Plus"
        case MonetizationStore.lifetimeProductID, MonetizationStore.legacyLifetimeProductID: "Ömür Boyu Plus"
        default: product.displayName
        }
    }

    private func subtitle(for product: Product) -> String {
        switch product.id {
        case MonetizationStore.weeklyProductID, MonetizationStore.legacyWeeklyProductID: "Kısa süreli Plus erişimi"
        case MonetizationStore.monthlyProductID, MonetizationStore.legacyMonthlyProductID: "Düzenli çalışma için Plus erişimi"
        case MonetizationStore.lifetimeProductID, MonetizationStore.legacyLifetimeProductID: "Tek ödeme, kalıcı Plus erişimi"
        default: product.description
        }
    }

    private func benefitRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.black))
                .foregroundStyle(BlitzTheme.success)
                .padding(.top, 1)

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BlitzTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func productPlanButton(_ product: Product) -> some View {
        Button {
            Task {
                await monetization.purchase(product)
            }
        } label: {
            planRowContent(
                title: title(for: product),
                subtitle: subtitle(for: product),
                price: product.displayPrice,
                trailingSystemImage: "chevron.right"
            )
        }
        .buttonStyle(.plain)
        .background(planRowBackground(stroke: BlitzTheme.accent.opacity(0.2)))
        .disabled(monetization.isLoading)
        .accessibilityHint("Satın alma ekranını açar")
    }

    private func unavailablePlanRow(_ plan: PremiumPlanPreview) -> some View {
        planRowContent(
            title: plan.title,
            subtitle: plan.subtitle,
            price: plan.price,
            trailingSystemImage: "lock.fill"
        )
        .opacity(0.72)
        .background(planRowBackground(stroke: BlitzTheme.dim.opacity(0.24)))
        .accessibilityHint("Bu seçenek App Store bağlantısı kurulunca satın alınabilir")
    }

    private func planRowContent(title: String, subtitle: String, price: String, trailingSystemImage: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(BlitzTheme.ink)

                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BlitzTheme.muted)
            }

            Spacer()

            Text(price)
                .font(.headline.weight(.black))
                .foregroundStyle(BlitzTheme.accent)

            Image(systemName: trailingSystemImage)
                .font(.subheadline.weight(.black))
                .foregroundStyle(BlitzTheme.accent)
                .frame(width: 18)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
    }

    private func planRowBackground(stroke: Color) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(BlitzTheme.cardGradient)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            }
    }
}

private struct PremiumPlanPreview: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let price: String
}

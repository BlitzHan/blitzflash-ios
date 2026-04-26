import Combine
import StoreKit
import SwiftUI

@MainActor
final class MonetizationStore: ObservableObject {
    static let weeklyProductID = "com.blitzhanlabs.BlitzFlash.premium.weekly"
    static let monthlyProductID = "com.blitzhanlabs.BlitzFlash.premium.monthly"
    static let lifetimeProductID = "com.blitzhanlabs.BlitzFlash.premium.lifetime"

    static let productIDs = [
        weeklyProductID,
        monthlyProductID,
        lifetimeProductID
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false

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
        errorMessage = nil
        do {
            products = try await Product.products(for: Self.productIDs)
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
        case Self.weeklyProductID: 0
        case Self.monthlyProductID: 1
        case Self.lifetimeProductID: 2
        default: 99
        }
    }
}

struct AdSlotView: View {
    @EnvironmentObject private var monetization: MonetizationStore
    var placement: String

    var body: some View {
        if !monetization.isPremium {
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        BlitzLogoMark(size: 64, cornerRadius: 16)

                        Text("BlitzFlash Plus")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(BlitzTheme.ink)

                        Text("Reklamsız çalış, modlar arasında kesintisiz ilerle.")
                            .font(.headline)
                            .foregroundStyle(BlitzTheme.muted)
                    }

                    VStack(spacing: 10) {
                        ForEach(monetization.sortedProducts, id: \.id) { product in
                            Button {
                                Task {
                                    await monetization.purchase(product)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title(for: product))
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(BlitzTheme.ink)

                                        Text(subtitle(for: product))
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(BlitzTheme.muted)
                                    }

                                    Spacer()

                                    Text(product.displayPrice)
                                        .font(.headline.weight(.black))
                                        .foregroundStyle(BlitzTheme.accent)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(BlitzTheme.cardGradient)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(BlitzTheme.accent.opacity(0.2), lineWidth: 1)
                                    }
                            )
                        }
                    }

                    if monetization.products.isEmpty {
                        BlitzCard(glow: BlitzTheme.accent) {
                            Text(monetization.isLoading ? "Seçenekler yükleniyor..." : "Satın alma seçenekleri App Store Connect ürünleri bağlanınca burada görünecek.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BlitzTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)
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

                    Text("Abonelikler Apple hesabın üzerinden yönetilir. Ömür boyu lisans tek seferlik satın almadır.")
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
        }
    }

    private func title(for product: Product) -> String {
        switch product.id {
        case MonetizationStore.weeklyProductID: "Haftalık Plus"
        case MonetizationStore.monthlyProductID: "Aylık Plus"
        case MonetizationStore.lifetimeProductID: "Ömür Boyu Plus"
        default: product.displayName
        }
    }

    private func subtitle(for product: Product) -> String {
        switch product.id {
        case MonetizationStore.weeklyProductID: "Kısa süreli reklamsız kullanım"
        case MonetizationStore.monthlyProductID: "Düzenli çalışma için reklamsız kullanım"
        case MonetizationStore.lifetimeProductID: "Tek ödeme, kalıcı reklamsız kullanım"
        default: product.description
        }
    }
}

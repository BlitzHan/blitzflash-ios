import Observation
import StoreKit
import SwiftUI

/// Plus satın alma durumu ve ücretsiz kullanıcının günlük hakkı.
/// Ücretsiz kullanıcı günde `freeDailyLimit` kart/soru cevaplar; Plus sınırsızdır.
@MainActor
@Observable
final class MonetizationStore {
    enum Plan: String, CaseIterable {
        case weekly = "com.blitzhanlabs.BlitzFlash.plus.weekly"
        case monthly = "com.blitzhanlabs.BlitzFlash.plus.monthly"
        case yearly = "com.blitzhanlabs.BlitzFlash.plus.yearly"
        case lifetime = "com.blitzhanlabs.BlitzFlash.premium.lifetime"

        static let subscriptionIDs = [weekly, monthly, yearly].map(\.rawValue)
    }

    static let freeDailyLimit = 40
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyURL = URL(string: "https://blitzhan.github.io/blitzflash/gizlilik.html")!

    private(set) var isPremium = false
    private(set) var usedToday = 0
    /// Hak bitince kök görünümdeki Plus sayfası açılır.
    var isPaywallPresented = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    @ObservationIgnored private let defaults = UserDefaults.standard

    init() {
        usedToday = defaults.string(forKey: "dailyUsageDay") == Self.today ? defaults.integer(forKey: "dailyUsageCount") : 0
    }

    var remainingToday: Int {
        max(Self.freeDailyLimit - usedToday, 0)
    }

    /// Bir kart/soru harcar. Hak yoksa Plus sayfasını açar ve `false` döner.
    func spend() -> Bool {
        if isPremium { return true }
        if defaults.string(forKey: "dailyUsageDay") != Self.today {
            defaults.set(Self.today, forKey: "dailyUsageDay")
            usedToday = 0
        }
        guard usedToday < Self.freeDailyLimit else {
            isPaywallPresented = true
            return false
        }
        usedToday += 1
        defaults.set(usedToday, forKey: "dailyUsageCount")
        return true
    }

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self?.refreshEntitlements()
            }
        }
        Task { await refreshEntitlements() }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Plan(rawValue: transaction.productID) != nil,
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPremium = active
        if active { isPaywallPresented = false }
    }

    private static var today: String {
        let day = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        return "\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)"
    }
}

/// Apple'ın hazır abonelik sayfası: fiyat, süre, otomatik yenileme metni, geri yükleme,
/// kod kullanma ve Kullanım Koşulları / Gizlilik bağlantılarını App Review'un beklediği
/// biçimde kendisi gösterir. Ömür boyu seçenek üst bölümde ayrı satır olarak durur.
struct PremiumPaywallView: View {
    @Environment(MonetizationStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(productIDs: MonetizationStore.Plan.subscriptionIDs) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    BlitzLogoMark(size: 56, cornerRadius: 14)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BlitzFlash Plus")
                            .font(.title.bold())
                        Text(store.remainingToday == 0 ? "Bugünkü ücretsiz hakkın bitti." : "Sınırsız çalış.")
                            .font(.subheadline)
                            .foregroundStyle(BlitzTheme.muted)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    benefit("infinity", "Günlük \(MonetizationStore.freeDailyLimit) soru sınırı kalkar")
                    benefit("globe", "İngilizce, İspanyolca ve Çekçe'nin tamamı")
                    benefit("square.grid.2x2", "Dört modda sınırsız oyun")
                    benefit("arrow.triangle.2.circlepath", "Tüm Apple cihazlarında geri yüklenir")
                }

                ProductView(id: MonetizationStore.Plan.lifetime.rawValue) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(BlitzTheme.accent)
                }
                .productViewStyle(.compact)
                .padding(14)
                .background(BlitzTheme.surface, in: .rect(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .frame(maxWidth: 520)
        }
        .subscriptionStoreControlStyle(.prominentPicker)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases, .redeemCode)
        .subscriptionStorePolicyDestination(url: MonetizationStore.termsURL, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: MonetizationStore.privacyURL, for: .privacyPolicy)
        .onInAppPurchaseCompletion { _, _ in
            await store.refreshEntitlements()
            if store.isPremium { dismiss() }
        }
        .tint(BlitzTheme.primary)
        .background(BlitzTheme.background)
    }

    private func benefit(_ icon: String, _ text: String) -> some View {
        Label {
            Text(text).foregroundStyle(BlitzTheme.ink)
        } icon: {
            Image(systemName: icon).foregroundStyle(BlitzTheme.primary)
        }
        .font(.subheadline)
    }
}

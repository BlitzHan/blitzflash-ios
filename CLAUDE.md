# CLAUDE.md

Bu dosya Claude Code'un bu repoda çalışırken uyacağı kuralları içerir.

## Proje Özeti

BlitzFlash — Türkçe konuşanlar için İngilizce, İspanyolca ve Çekçe kelime çalışma uygulaması (SwiftUI, yalnız iPhone). Tüm UI metinleri Türkçe ve doğru Türkçe karakterlerle yazılır. Bundle ID `com.blitzhanlabs.BlitzFlash`, ASC Apple ID `6763912751`.

## Build & Run

```bash
xcodebuild -project BlitzFlash.xcodeproj -scheme BlitzFlash -destination 'generic/platform=iOS Simulator' build
```

Harici bağımlılık ve test target yok. Paylaşılan şema `Products.storekit` yerel StoreKit yapılandırmasını kullanır: Plus ekranını gerçek ürünlerle görmek için uygulamayı **Xcode'dan** çalıştır (`simctl launch` StoreKit yapılandırmasını yüklemez, sayfa "Subscription Unavailable" gösterir).

Hedefler: iOS 17.0+, iPhone (`TARGETED_DEVICE_FAMILY = 1`). iOS 26+ API'leri (`glassEffect`, `.glassProminent`) `if #available(iOS 26, *)` ile sarılır — örnek `View.blitzButton`.

## Mimari

- **Durum:** `@Observable` (`MonetizationStore`), ortamla enjekte edilir: `@Environment(MonetizationStore.self)`. `ObservableObject` kullanma.
- **Veri:** `VocabularyData.words` (889 kelime) ana liste; `SpanishVocabularyData` / `CzechVocabularyData` İngilizce anahtarla eşlenir. Dile göre liste için `LearningLanguage.words` kullan (çevirisi olmayan kelimeyi eler). Hedef dil metni için `targetTerm/targetSentence/targetPronunciation`. `targetSentence` yer tutucu cümlelerde ("La palabra …", "Slovo …") `nil` döner — gösterme.
- **Rastgele seçim:** tekrar etmeyen seçim için `WordPicker`.
- **Beklemeler:** `DispatchQueue.main.asyncAfter` yerine `Delay` (görünüm kapanınca `cancel()`); süre sayacı `.task(id:)` döngüsü.
- **Ortak bileşenler (`BlitzTheme.swift`):** `BlitzCard`, `StatPill`, `ResultCard`, `BlitzButtonLabel` + `.blitzButton(tint:)`, `.blitzAnswerField()`, `.blitzScreen()`. Yeni ekran bunları kullanır; düğme stili elle yazılmaz.
- **Haptik:** `.sensoryFeedback(.success/.error, trigger:)`.

### Plus ve günlük hak

- Ürünler `MonetizationStore.Plan`: `plus.weekly`, `plus.monthly`, `plus.yearly` (abonelik grubu "BlitzFlash Plus", ID 22053982) ve `premium.lifetime` (non-consumable). ID'ler ASC ile birebir aynı olmalı.
- Ücretsiz kullanıcı günde `freeDailyLimit` (40) kart/soru cevaplar. Her cevap noktası önce `monetization.spend()` çağırır; `false` dönerse işlem yapılmaz ve kökteki Plus sayfası (`isPaywallPresented`) kendiliğinden açılır.
- Plus sayfası Apple'ın `SubscriptionStoreView`'u: fiyat, süre, yenileme metni, geri yükleme, kod kullanma, Kullanım Koşulları ve Gizlilik bağlantısı oradan gelir. Elle fiyat yazma.
- Reklam yok. Plus'ı "reklamsız" diye tanıtma (uygulamada, ASC'de, açıklamalarda).

### iPhone Duo / ekran sınıfları

- `ContentView` kökte boyutu ölçer ve `\.blitzLayout` (`BlitzLayout`) yayar: `isWide` = Duo iç ekranı **yatay** (genişlik ≥ 560 ve genişlik > yükseklik), `isShort` = yükseklik < 660 (Duo dış ekranı, iPhone SE).
- İki bölmeli düzen `AdaptiveSplit { birincil } secondary: { ikincil }`: iç ekranda bölmeler arası boşluk ekranın ortasındaki katlanma çizgisine denk gelir (`ScreenCenterReader`), diğer ekranlarda alt alta dizer. Mod ekranları kartı birincil, cevap/istatistik/düğmeleri ikincil bölmeye koyar.
- Yön: Info.plist iPhone'da yatayı açar (yoksa Duo iç ekranı uyumluluk penceresinde açılır); `AppDelegate` kısa kenarı < 600pt olan ekranları dikeye kilitler.
- Duo dış ekranında iOS 27 durum çubuğunu ve araç çubuğunu sağ kenara alır; içerik genişliği ~420pt kalır.
- Simülatör: "iPhone Duo" cihazı; duruş (katlı/açık) Device Hub'daki düğmelerle değişir. Ekran görüntüsü için `xcrun simctl io <udid> enumerate` ile iç (2007 genişlik) / dış (1398) ekran UUID'sini al, `screenshot --display=<uuid>`.

## Gizlilik / Dağıtım

- Destek ve gizlilik sayfaları `../../fiyatmatik/Fiyatmatik/docs/blitzflash/` altında; o klasör herkese açık **BlitzHan/blitzhan.github.io** reposunun kaynağıdır.
  - Destek (ASC Support URL): `https://blitzhan.github.io/blitzflash/`
  - Gizlilik (ASC Privacy Policy URL ve `MonetizationStore.privacyURL`): `https://blitzhan.github.io/blitzflash/gizlilik.html`
- ASC gizlilik beyanı "Data Not Collected". Reklam ya da analitik eklenirse beyan, gizlilik sayfası ve yaş derecelendirmesi aynı sürümde güncellenir.
- Yeni IAP/abonelik ürünü eklenince: ASC'de oluştur, sürüm sayfasındaki "In-App Purchases and Subscriptions" bölümüne ekle, `Products.storekit` ve `Plan`'a ekle.

## App Store Metinleri (Sabit Yazım Standardı)

Her sürümde ASC'deki dört alan — **Promotional Text**, **Description**, **What's New in This Version**, **Keywords** — aşağıdaki kurallarla yeniden üretilir ve `AppStoreMetadata/<sürüm>.md` dosyasına kaydedilir (örnek: `AppStoreMetadata/2.0.md`). Fiyatmatik ile aynı standart; dil daima Türkçe.

**Ortak ton:** Sade ve öğretici. Fayda vurgulu, öğrenciye ve günlük kullanıcıya hitap eder. Abartılı pazarlama dili ("muhteşem", "en iyi", "yepyeni") ve ünlem işareti yok. Okura "siz" diye hitap et.

**Ortak kurallar:**
- ASC alanları düz metindir: Markdown yok. Başlıklar kendi satırında durur.
- Emoji, rakip/marka adı, fiyat ve "ücretsiz/indirim" gibi değişebilen bilgi yok.
- **Uygulamada olmayan özelliği yazma** (2.3.1). Yazmadan önce koddaki gerçek durumu kontrol et: günlük sınır değeri (`freeDailyLimit`), kelime sayısı (`VocabularyData.words.count`), diller (`LearningLanguage`), Plus planları (`Plan`).
- Cihaz adları Apple yazımıyla: iPhone, iPhone Duo.

### Promotional Text (≤ 170)
Tek paragraf, 1-2 cümle: ana fayda + öne çıkan yenilik. Sürüm göndermeden güncellenebilir.

### Description (≤ 4000, hedef 1200-2000)
Sıra sabit:
```
[Giriş: "BlitzFlash, ..." ile başlar; kime ve ne işe yarar. 1-2 cümle.]

ÇALIŞMA MODLARI
• [mod: tek cümle]

DİLLER VE KELİMELER
• ...

BLITZFLASH PLUS
• [günlük sınır, planlar, geri yükleme]

CİHAZ DESTEĞİ
• [iPhone / iPhone Duo]

GİZLİLİK
• ...

[Abonelik yenileme cümlesi + Kullanım Koşulları ve Gizlilik Politikası bağlantıları]

[Kapanış: 1 cümle, kullanım senaryosu.]
```
Başlıklar BÜYÜK HARF, maddeler `• ` ile başlar, madde sonunda nokta yok. İlk 3 satırda ana fayda.

### What's New (≤ 4000)
Her madde: kendi satırında özellik adı, altında 1-2 cümle; maddeler arası bir boş satır. Önce yenilikler (önem sırasıyla), en sonda daima `Hata Düzeltmeleri ve İyileştirmeler` (son cümle: "Genel kararlılık ve performans iyileştirmeleri yapıldı.").

### Keywords (≤ 100 karakter)
Virgülle ayrılmış, boşluksuz, sonda virgül yok. Ad (BlitzFlash), alt başlıktaki kelimeler (kelime, öğrenmek, hızlı, yol) ve kategori (eğitim) tekrar edilmez. Çok kelimeli ifadeleri böl. 100 karakterin tamamını kullanmayı hedefle.

### Her sürümde kontrol listesi
- Version (`MARKETING_VERSION`) ASC'de yayındaki sürümden büyük; build numarası her yüklemede artar.
- Satın alma ürünleri sürüme ekli mi, açıklamaları uygulamayla tutarlı mı.
- Paid Apps Agreement aktif mi (Business > Agreements).
- Support / Privacy URL'leri açılıyor mu.
- Ekran görüntüleri: iPhone 6.1" (1206×2622) ve iPhone Duo (dış 1398×2034, iç 2853×2007).
- Yaş derecelendirmesine yeni soru eklendiyse cevapla.

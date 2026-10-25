# BlitzFlash Plus Kurulumu

Plus, ücretsiz kullanımdaki günlük 40 soru sınırını kaldırır. Reklam yok. Kod tarafı hazır (`MonetizationStore.swift`); satışın açılması için App Store Connect'te aşağıdakilerin hepsi tamam olmalı.

## Ürünler

| Ürün | Tür | Product ID | Fiyat (TR) | ASC durumu (25.10.2026) |
| --- | --- | --- | --- | --- |
| Haftalık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.weekly` | ₺24,99 | Prepare for Submission |
| Aylık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.monthly` | ₺89,99 | Prepare for Submission |
| Yıllık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.yearly` | ₺499,99 ($9,99) | Oluşturuldu (Apple ID 6826833452), inceleme görseli eksik |
| Ömür Boyu Plus | Non-consumable | `com.blitzhanlabs.BlitzFlash.premium.lifetime` | ₺999,99 | Prepare for Submission |

Abonelikler "BlitzFlash Plus" grubunda (ID 22053982). Hepsi aynı hizmeti verdiği için grupta aynı seviyeye (level) konabilir.

## Neden şimdiye kadar çalışmadı

1. **Ürünler hiç incelemeye gitmedi.** İlk abonelik grubu ve ilk non-consumable ancak bir uygulama sürümüyle birlikte gönderilebilir. 1.8 gönderilirken sürüm sayfasındaki "In-App Purchases and Subscriptions" bölümüne eklenmedikleri için onaylanmadılar; App Store bu yüzden ürün döndürmüyor.
2. **Paid Apps Agreement aktif değil** ("Pending User Info"). Vergi formu (W-8BEN) eksik, banka hesabı işlemde. Bu sözleşme aktif olmadan ürünler TestFlight'ta bile yüklenmez.
3. **Plus'ın karşılığı yoktu.** Reklamlar kapalıyken "reklamsız" Plus satmak App Review'da reddedilir. 2.0'da Plus günlük sınırı kaldırıyor.
4. **Uygulamada Plus ekranına giden yol yoktu** (son tasarım değişikliğinde taç düğmesi kaldırılmıştı).

## Gönderimden önce yapılacaklar

Yapıldı (25.10.2026): yıllık abonelik oluşturuldu ve 175 bölgede fiyatlandı; ömür boyu ₺999,99 yapıldı; dört ürünün Türkçe açıklaması ve İngilizce inceleme notu günlük sınır diliyle güncellendi; grup görünen adı "BlitzFlash Plus" oldu; ASC'de 2.0 sürümü açıldı, Support URL ve Privacy Policy URL destek sitesine bağlandı.

Kalan:
1. Business > Agreements: W-8BEN vergi formunu doldur, banka hesabının onaylanmasını bekle. Paid Apps Agreement "Active" olmalı.
2. Dört ürünün "Review Information > Screenshot" alanına `AppStoreMetadata/plus-review-2.0.jpg` yükle (yıllıkta zorunlu; diğerlerindeki eski görsel reklam vaadi ve eski fiyat gösteriyor).
3. 2.0 build'ini yükle, sürüm sayfasında "In-App Purchases and Subscriptions" bölümüne dört ürünü de ekle, metinleri `AppStoreMetadata/2.0.md`'den yapıştır ve gönder.
4. App Review notuna: "Free users can answer 40 questions per day; when the limit is reached the Plus paywall opens. It also opens from the crown button on the home screen."

## Yerel test

Uygulamayı Xcode'dan çalıştır; paylaşılan şema `Products.storekit` dosyasını yükler ve dört ürün de simülatörde satın alınabilir görünür. Günlük hakkı sıfırlamak için uygulamayı silip yeniden kur.

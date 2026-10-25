# BlitzFlash Plus Kurulumu

Plus, ücretsiz kullanımdaki günlük 40 soru sınırını kaldırır. Reklam yok. Kod tarafı hazır (`MonetizationStore.swift`); satışın açılması için App Store Connect'te aşağıdakilerin hepsi tamam olmalı.

## Ürünler

| Ürün | Tür | Product ID | Fiyat (TR) | ASC durumu (25.10.2026) |
| --- | --- | --- | --- | --- |
| Haftalık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.weekly` | ₺24,99 | Prepare for Submission |
| Aylık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.monthly` | ₺89,99 | Prepare for Submission |
| Yıllık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.plus.yearly` | ₺499,99 ($9,99) | Prepare for Submission (Apple ID 6826833452) |
| Ömür Boyu Plus | Non-consumable | `com.blitzhanlabs.BlitzFlash.premium.lifetime` | ₺999,99 | Prepare for Submission |

Abonelikler "BlitzFlash Plus" grubunda (ID 22053982). Hepsi aynı hizmeti verdiği için grupta aynı seviyeye (level) konabilir.

## Neden şimdiye kadar çalışmadı

1. **Ürünler hiç incelemeye gitmedi.** İlk abonelik grubu ve ilk non-consumable ancak bir uygulama sürümüyle birlikte gönderilebilir. 1.8 gönderilirken sürüm sayfasındaki "In-App Purchases and Subscriptions" bölümüne eklenmedikleri için onaylanmadılar; App Store bu yüzden ürün döndürmüyor.
2. **Paid Apps Agreement aktif değil** ("Pending User Info"). Vergi formu (W-8BEN) eksik, banka hesabı işlemde. Bu sözleşme aktif olmadan ürünler TestFlight'ta bile yüklenmez.
3. **Plus'ın karşılığı yoktu.** Reklamlar kapalıyken "reklamsız" Plus satmak App Review'da reddedilir. 2.0'da Plus günlük sınırı kaldırıyor.
4. **Uygulamada Plus ekranına giden yol yoktu** (son tasarım değişikliğinde taç düğmesi kaldırılmıştı).

## Gönderimden önce yapılacaklar

Yapıldı (25.10.2026): yıllık abonelik oluşturuldu ve 175 bölgede fiyatlandı; ömür boyu ₺999,99 yapıldı; dört ürünün Türkçe açıklaması ve İngilizce inceleme notu günlük sınır diliyle güncellendi; grup görünen adı "BlitzFlash Plus" oldu; ASC'de 2.0 sürümü açıldı, Support URL ve Privacy Policy URL destek sitesine bağlandı.

Ayrıca yapıldı: dört ürüne yeni inceleme görseli yüklendi; 2.0 metinleri, App Review notu girildi; build 2.0 (1) yüklenip sürüme bağlandı.

Kalan:
1. W-8BEN vergi formu (aşağıdaki adımlar) ve banka onayı → Paid Apps Agreement "Active".
2. Sözleşme aktif olunca 2.0 sürüm sayfasında "In-App Purchases and Subscriptions" bölümü görünür: dört ürünü ekle ve "Submit for Review". (Apple bu bölümü sözleşme aktif olmadan gizliyor.)

## W-8BEN vergi formu (adım adım, ~10 dakika)

Bu form ABD'ye "ABD vatandaşı değilim, Türkiye'de vergi mükellefiyim" beyanıdır. Doldurulmazsa Paid Apps Agreement aktif olmaz ve hiçbir satın alma çalışmaz.

1. appstoreconnect.apple.com → **Business** → üstte "One or more tax forms still need to be completed" uyarısındaki **Add Tax Form**'a tıkla (ya da Tax Forms tablosundaki "U.S. Form W-8BEN" satırı).
2. "Are you a U.S. citizen, resident or entity?" → **No**.
3. Hesap türü → **Individual / Sole Proprietor** (şahıs olarak çalışıyorsan).
4. **Part I — Kimlik bilgileri:**
   - Name: kimlikteki ad soyad (Türkçe karakter yerine İngilizce harf: YILDIRIM YIGIT)
   - Country of citizenship: **Turkey**
   - Permanent residence address: Türkiye'deki ikamet adresin (posta kutusu olmaz)
   - U.S. TIN: **boş bırak**
   - Foreign TIN: **T.C. kimlik numaran** (Türkiye'de şahısların vergi numarası budur)
   - Date of birth: doğum tarihin
5. **Part II — Vergi antlaşması:** Türkiye ile ABD arasında çifte vergilendirmeyi önleme antlaşması var. "Claim tax treaty benefits" → **Yes**, ülke **Turkey**. Apple'ın ekranında madde ve oran (Article / Rate) seçenekleri çıkar; uygulama satışı geliri için ekrandaki önerilen seçimi kullan. Emin değilsen mali müşavirine sor. Bu bölüm yalnızca ABD'deki satışlardan kesilecek vergiyi azaltır; boş bırakırsan ABD satışlarından %30 kesilir.
6. **Part III — İmza:** "I certify…" kutularını işaretle, imza alanına adını yaz, "Capacity" → **Individual**, tarih bugünün tarihi. **Submit**.
7. Formun durumu birkaç dakika içinde "Active" olur. Banka hesabı ("Processing") 24 saat içinde onaylanınca Paid Apps Agreement **Active** olur.

Bu iki durum Active olunca söyle; 2.0'ı ürünlerle birlikte incelemeye gönderelim.

## Yerel test

Uygulamayı Xcode'dan çalıştır; paylaşılan şema `Products.storekit` dosyasını yükler ve dört ürün de simülatörde satın alınabilir görünür. Günlük hakkı sıfırlamak için uygulamayı silip yeniden kur.

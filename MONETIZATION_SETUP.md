# BlitzFlash Para Kazanma Kurulumu

Bu dosya, BlitzFlash'i ücretsiz yayınlayıp reklamlardan gelir elde etmek ve ödeme yapan kullanıcılara reklamsız kullanım sunmak için izleyeceğin basit yol haritasıdır.

## Şu An Kodda Hazır Olanlar

- Uygulama ücretsiz kullanılabilir.
- Reklam alanları hazırlandı.
- Plus alanı hazırlandı.
- Haftalık, aylık ve ömür boyu satın alma altyapısı hazırlandı.
- Plus satın alan kullanıcı reklam görmeyecek şekilde altyapı kuruldu.

Not: Gerçek para kazanmak için App Store Connect ve AdMob tarafında aşağıdaki adımları senin hesabında açmamız gerekiyor.

## App Store Connect'te Yapılacaklar

1. App Store Connect'e gir.
2. BlitzFlash uygulamasını aç.
3. Sol menüden `Features` veya `Özellikler` bölümüne gir.
4. `In-App Purchases` veya `Uygulama İçi Satın Almalar` bölümünü aç.
5. Aşağıdaki 3 ürünü oluştur.

| Ürün Adı | Tür | Product ID |
| --- | --- | --- |
| Haftalık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.premium.weekly` |
| Aylık Plus | Otomatik yenilenen abonelik | `com.blitzhanlabs.BlitzFlash.premium.monthly` |
| Ömür Boyu Plus | Tek seferlik satın alma | `com.blitzhanlabs.BlitzFlash.premium.lifetime` |

Çok önemli: `Product ID` değerlerini birebir aynı yaz. Harf, nokta veya büyük/küçük harf farkı olursa uygulama ürünleri bulamaz.

## Fiyat Önerisi

Başlangıç için çok basit bir fiyat mantığı:

- Haftalık Plus: düşük fiyatlı deneme seçeneği
- Aylık Plus: ana satın alma seçeneği
- Ömür Boyu Plus: aylığa göre daha yüksek, tek seferlik kalıcı seçenek

Ömür boyu seçeneği çok ucuz yapma. Çünkü kullanıcı bir kez alır ve bir daha ödeme yapmaz.

## Reklam İçin Yapılacaklar

Gerçek reklam göstermek için AdMob kullanacağız.

1. Google AdMob hesabına gir.
2. Yeni iOS uygulaması oluştur.
3. Bundle ID olarak şunu yaz:

```text
com.blitzhanlabs.BlitzFlash
```

4. Banner reklam birimi oluştur.
5. AdMob sana bir reklam birimi ID'si verecek.
6. O ID'yi bana gönder.
7. Ben Google Mobile Ads SDK'yı projeye ekleyip gerçek reklamı bağlayacağım.

Şu an uygulamadaki reklam alanları sadece hazır yer tutucu olarak duruyor. Yani tasarım ve premium kontrolü hazır, gerçek reklam ağı henüz bağlanmadı.

## İlk Sürüm İçin Tavsiye

İlk başta sadece banner reklam kullanalım.

Önerilen reklam yerleri:

- Ana sayfa
- Serbest Mod
- Yazarak Tahmin
- Cümle Tamamla
- Kelime Avı

Tam ekran reklamı şimdilik eklemeyelim. Öğrenme akışını bölebilir ve kullanıcıyı uygulamadan soğutabilir.

## Senin Yapman Gereken En Basit Liste

1. App Store Connect'te 3 satın alma ürünü oluştur.
2. Product ID'leri yukarıdakiyle birebir aynı yaz.
3. AdMob'da iOS uygulaması oluştur.
4. Banner reklam birimi oluştur.
5. Bana AdMob reklam birimi ID'sini gönder.

Bu 5 adım tamamlanınca kod tarafında gerçek reklam bağlantısını yapabiliriz.

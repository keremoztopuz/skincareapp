# Skinner — App Store Başvuru Yönergesi

26 Ağustos 2026 durumuyla yazıldı. Sırayla ilerle; her adımın sonunda ne
göreceğin yazıyor.

## 0. Başvurudan önce kapatılması gereken maddeler

| # | İş | Nerede | Durum |
| --- | --- | --- | --- |
| 1 | `com.keremoztopuz.skincare.pro.weekly` ve `...pro.lifetime` ürünlerini `skanner_pro` entitlement'ına bağla | RevenueCat → Entitlements | **Açık — kritik** |
| 2 | Boş kalan `$rc_monthly` paketini `default` offering'den sil | RevenueCat → Offerings | Açık (kozmetik) |
| 3 | Haftalık ürünün review screenshot'ını kontrol et (13 KB'lık bir dosya görünüyor) | App Store Connect → Subscriptions | Açık |
| 4 | App Store screenshot'ları (6.9") | ASC → App Store sekmesi | Hazırlanıyor |
| 5 | Build yükle (Archive → Distribute) | Xcode Organizer | Açık |

**1. madde olmadan başvurma.** Entitlement'a bağlı ürün yoksa satın alma
tamamlanır, para çekilir ve uygulama Pro'yu açmaz. Apple bunu 3.1.1 /
"in-app purchase not working" gerekçesiyle reddeder.

Yol: RevenueCat → Project `skanner` → Entitlements → `skanner_pro` →
**Attach products** → `SkinCare Pro Weekly` + `Skincare Pro Lifetime` seç → Save.
Ardından `Purchases.shared.getCustomerInfo` ile sandbox'ta bir satın alma
deneyip `entitlements["skanner_pro"].isActive == true` görmelisin.

## 1. Ürün durumu (doğrulandı)

| Ürün | ID | Süre | TR | US | EU | Durum |
| --- | --- | --- | --- | --- | --- | --- |
| Weekly | `com.keremoztopuz.skincare.pro.weekly` | ONE_WEEK | ₺99,99 | $3.99 | €3,99 | READY_TO_SUBMIT |
| Lifetime | `com.keremoztopuz.skincare.pro.lifetime` | — | ₺699,99 | $12.99 | €14,99 | READY_TO_SUBMIT |
| Monthly (emekli) | `com.keremoztopuz.skincare.pro.monthly` | ONE_MONTH | ₺99,99 | $3.99 | €3,99 | Hiçbir pakete bağlı değil |

Haftalık üründe **3 günlük ücretsiz deneme** tanımlı (26 Ağustos 2026'dan
itibaren, tüm bölgelerde). Uygulama denemeyi StoreKit'ten okur: buton
"3 Günlük Ücretsiz Denemeyi Başlat", altındaki satır "Sonrasında haftalık ₺99,99"
olur. Metinlerde sabitlenmiş bir deneme vaadi yok.

## 2. Screenshot gereksinimleri

- **Zorunlu boyut:** 6.9" iPhone — **1320 × 2868** px, dikey. (iPhone 17 Pro Max
  simülatöründen alınan görüntü tam bu boyutta çıkıyor.)
- Adet: en az 3, en fazla 10. Önerilen sıra 5–6 kare.
- PNG, alpha kanalı **olmadan**, köşe yuvarlaması/çerçeve eklenmeden.
- Uygulama iPhone-only (`TARGETED_DEVICE_FAMILY = 1`), yalnız dikey — iPad seti
  gerekmiyor.
- İçerik gerçek uygulama ekranı olmalı; sahte veri veya montaj Apple'ın
  2.3.3 maddesine takılır.

Önerilen kareler:

1. Onboarding — "Skinner'a Hoş Geldiniz"
2. Ana ekran — selamlama, istatistik kartları, rutin özeti
3. Tarama ekranı — yüz çerçevesi
4. Sonuç ekranı — genel skor + beş koşul çubuğu
5. Rutin ekranı — sabah/akşam adımları
6. Geçmiş — analiz listesi ve trend

## 3. App Store Connect adımları

### 3.1 App Information
- Name: **Skinner** · Subtitle: **Kişisel cilt analizi ve rutin takibi**
- Category: Health & Fitness (birincil), Lifestyle (ikincil)
- Content Rights: üçüncü taraf içerik yok
- Age Rating: 12+ seçilmesi bekleniyor (medikal/tedavi bilgisi yok, kozmetik
  görünüm değerlendirmesi var)

### 3.2 Pricing and Availability
- Uygulama ücretsiz, tüm bölgeler.

### 3.3 App Privacy
- **Photos:** toplanıyor, amaç *App Functionality*, kullanıcıya **bağlı değil**,
  takip için kullanılmıyor. Yüz kırpımı analiz için proxy'ye gönderilir, kalıcı
  saklanmaz.
- **Identifiers / Usage Data:** RevenueCat abonelik durumu için anonim app user
  ID. Takip yok.
- Privacy Policy URL: `https://keremoztopuz.github.io/skincare-legal/privacy`
- EULA: standart Apple EULA yeterli; özel şartlar
  `https://keremoztopuz.github.io/skincare-legal/terms`

### 3.4 Subscriptions
- Grup: `skinner Pro` — grup ekranında lokalize isim girili olmalı (tr: skinner Pro)
- Her ürün için: display name, description, review screenshot, review notes.
- Weekly ürününde trial'ın "3 Days, All Territories" göründüğünü doğrula.

### 3.5 Version Information
- Screenshot'lar (bkz. bölüm 2), Promotional text, Description, Keywords,
  Support URL, Marketing URL — metinler `APP_STORE_METADATA_DRAFT.md` içinde
  hazır, tr ve en olarak gir.
- "What's New": ilk sürümde gerekmez.

### 3.6 Build
```
Xcode → Product → Archive → Distribute App → App Store Connect → Upload
```
- `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1`.
- Export compliance: uygulama yalnızca HTTPS kullanıyor →
  "Does your app use encryption?" → *Yes, only exempt encryption (HTTPS)*.
  Bunu `ITSAppUsesNonExemptEncryption = NO` olarak Info.plist'e koyarsan her
  yüklemede sorulmaz.
- Yükleme sonrası build "Processing" bitene kadar (10–30 dk) bekle, sonra
  sürüme ekle.

### 3.7 App Review Information
- Demo hesap gerekmez (uygulama hesap açmıyor) — bunu nota yaz.
- Notes alanına: paywall'un onboarding'in profil adımından hemen sonra
  göründüğü, Profil sekmesindeki "Pro'ya Geç" ile de açıldığı, analizin
  internet gerektirdiği ve yüz görüntüsünün kalıcı saklanmadığı yazılmalı.
- Attachment: kameranın simülatörde çalışmadığını, incelemecinin gerçek cihazda
  denemesi gerektiğini belirt.

### 3.8 Submit
- "Add for Review" → "Submit to App Review".
- Otomatik yayın yerine **Manually release this version** seç; ilk sürümde
  onay sonrası kontrollü yayınlamak daha güvenli.

## 4. Sık red sebepleri — bu uygulamada riskli olanlar

| Madde | Risk | Önlem |
| --- | --- | --- |
| 3.1.1 | Satın alma Pro'yu açmıyor | Bölüm 0, madde 1 |
| 2.1 | İncelemeci kamerayı simülatörde deneyip "çalışmıyor" diyor | Review notunda gerçek cihaz uyarısı |
| 1.4.1 / 5.1.1(x) | Sağlık iddiası gibi okunan metin | Uygulama "kozmetik görünüm" dili kullanıyor; mağaza metninde de teşhis/tedavi kelimesi geçmemeli |
| 3.1.2 | Abonelik şartları paywall'da eksik | Fiyat, süre ve otomatik yenileme satırı paywall'da mevcut; ekran görüntüsüyle nota ekle |
| 5.1.1 | Gizlilik politikası erişilemez | Legal site canlı (GitHub Pages, HTTP 200) |

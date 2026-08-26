# App Store Metadata Draft

Bu taslak App Store Connect'e kopyalanmadan once son urun kararlarina gore kontrol edilmelidir.

Iki kural bu dosyanin tamamini yonetiyor:

1. **Tibbi iddia yok.** Uygulama teshis koymaz. Metinlerde "akne", "egzama", "sedef", "tedavi", "iyilestirir" gibi klinik terimler kullanilmaz; gorunur cilt ozellikleri gundelik dille anlatilir (Breakouts, Redness, Wrinkles, Eye Bags, Pigmentation, Hydration). Uygulama arayuzu de ayni terimleri kullanir.
2. **Analiz tamamen bulutta calisir.** Cihaz uzerinde model yoktur, "hibrit" bir mimari yoktur. Yuz tespiti (Vision) disinda tum skorlar bulut servisinden gelir. Onceki taslaktaki "on-device CoreML" ifadesi gercek mimariyi yansitmiyordu ve kaldirildi.

---

## App Name

Skinner

## Subtitle

Personal skin analysis and routine tracker

## Promotional Text

Track visible skin changes over time and build a simple daily routine from your iPhone.

## Description

Skinner helps you look at your skin's visible features, follow how they change over time, and organize a personal skincare routine.

Take a photo with your iPhone camera and Skinner reviews six visible features: breakouts, redness, wrinkles, eye bags, pigmentation, and hydration-related signs. Each scan is saved on your device, so you can compare two scans side by side and see what changed.

Key features:
- Six visible-feature readings from a single photo
- Compare any two scans and see the difference
- Scan history stored on your device
- Personal morning and evening routine builder
- Product and article library
- Available in English and Turkish

How analysis works: your photo is cropped to your face on your iPhone, then sent securely to our service for processing. Photos are not stored permanently by us and are never used to build an advertising profile. An internet connection is required to run a scan; your history, profile, and routine work offline.

Important: Skinner is a cosmetic tracking tool. It does not diagnose, treat, or provide medical advice, and it is not a substitute for a dermatologist. If you have a concern about your skin, consult a qualified healthcare professional.

## Keywords

skin analysis, face scan, skin tracker, skincare routine, complexion, blemish, redness, wrinkles, hydration, beauty

Note: high-traffic clinical terms (e.g. "acne") are deliberately left out to keep the listing consistent with the non-medical positioning. If discoverability matters more than that consistency, adding them to the keyword field only — never to the description — is the lower-risk compromise.

## Category

Primary: Health & Fitness

Alternative: Lifestyle

## Age Rating

TODO: Confirm. Expected 4+ / 12+. No user-generated content, no social features, no medical claims.

## Support URL

TODO: Add public support page URL.

## Marketing URL

TODO: Optional. Leave blank if there is no landing page.

## Privacy Policy URL

TODO: Publish `PRIVACY_POLICY_DRAFT.md` as a public web page and add its URL. The same URL must match the in-app legal links in `LegalLinks.swift`.

## Terms of Use URL

Use Apple's Standard EULA if there is no custom terms page:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## Review Notes

Skinner analyzes visible skin features from a single photo. There is no on-device analysis model.

Processing flow:
1. The user takes a photo with the front camera.
2. The photo is cropped to the detected face on-device using Apple's Vision framework.
3. The crop is sent over HTTPS to our own backend service, which strips image metadata, downscales the image, and forwards it to Google's Gemini API (Vertex AI) for processing.
4. Six numeric readings are returned and shown to the user. The crop is not stored permanently by our service. Google retains requests briefly for abuse monitoring only; they are not used to train models.

No account or sign-in is required. Profile details and scan history are stored only on the device using Core Data and are never uploaded. Product and article content is read from our backend; no user data is sent with those requests.

The app shows a medical disclaimer during onboarding that the user must accept before continuing, and repeats a non-diagnostic notice on every result screen.

Free tier: 5 scans per month, breakouts and redness readings only, last 5 analyses visible. Paid tier unlocks unlimited scans, all six readings, full history, and routine recommendations.

## App Privacy Draft

Confirm these answers against the final implementation before submitting.

Data collected:
- **Photos** — the face crop is transmitted for processing on each scan. Not linked to an identity, not used for tracking, not stored permanently by us.
- **Other user content** — self-reported profile (name, age, gender, skin type). Stored on device only; not transmitted.
- **Purchases** — subscription status handled by Apple and RevenueCat.
- **Identifiers** — RevenueCat assigns an anonymous app user ID for entitlement lookup.

Data linked to the user:
- Purchase and entitlement data via Apple / RevenueCat.

Data not collected:
- No contacts, no location, no browsing history, no advertising identifiers.

Tracking:
- None. No third-party advertising SDKs.

Sensitive data:
- Face images are processed to produce cosmetic readings. Declare under "Photos" with the "App Functionality" purpose. Do not declare a Health purpose — the app makes no health claims.

## Subscription Metadata

### Monthly

Product ID: `com.keremoztopuz.skincare.pro.monthly`

Reference name: Monthly Pro

Display name: Skinner Pro

Description: Unlimited monthly scans, all six visible-feature readings, full scan history, and routine recommendations.

### Lifetime

Product ID: `com.keremoztopuz.skincare.pro.lifetime`, attached to the RevenueCat `$rc_lifetime` package of the `default` offering. Without that package the lifetime card falls back to placeholder pricing.

Reference name: Lifetime Pro

Display name: Skinner Lifetime

Description: One-time purchase. Everything in Pro, with no subscription and no renewal.

### Entitlement

Both products must unlock the RevenueCat entitlement `skanner_pro`. The app treats this entitlement as the single source of premium status, so a product that is not attached to it takes the user's money without unlocking anything.

### Pricing

The app's placeholder prices — shown only until StoreKit returns the real storefront price — are:

| Storefront | Monthly | Lifetime |
| --- | --- | --- |
| US | $1.99 | $17.99 |
| EU | €1,99 | €19,99 |
| TR | ₺99,99 | ₺699,99 |

Turkey is the pricing base. The monthly subscription was equalized from the TR
price across every territory, which is why the US monthly sits at $1.99.

TODO: the lifetime product was **not** equalized — RevenueCat's equalize
endpoint rejects non-consumables, so only the TR price moved and every other
territory still carries the tier set from the old $17.99 base. Equalize it from
Turkey in App Store Connect, then update the table and
`SubscriptionManager.FallbackPrice`.

### Introductory offer

TODO: Decide whether to offer a free trial. Nothing in the app promises one — the paywalls read the offer from StoreKit and mention a trial only when App Store Connect actually carries one, using the store's own unit ("1 month free", not "30 days"). With no offer configured the buttons simply read "Get Pro".

---

## Turkish Localization (tr)

App Store Connect'te tr yerel ayari icin kullanilacak metinler. Uygulama Turkce destekledigi icin magaza metni de Turkce girilmelidir.

**Isim:** Skinner

**Alt Baslik:** Kisisel cilt analizi ve rutin takibi

**Tanitim Metni:** Cildinizdeki gorunur degisimleri zaman icinde takip edin ve gunluk rutininizi olusturun.

**Aciklama:**

Skinner cildinizin gorunur ozelliklerine bakmaniza, bunlarin zaman icinde nasil degistigini izlemenize ve kisisel bir cilt bakim rutini olusturmaniza yardimci olur.

iPhone kameranizla bir fotograf cekin; Skinner alti gorunur ozelligi degerlendirir: sivilce, kizariklik, kirisiklik, goz alti torbalari, leke ve nem belirtileri. Her tarama cihazinizda saklanir, boylece iki taramayi yan yana karsilastirip neyin degistigini gorebilirsiniz.

Ozellikler:
- Tek fotograftan alti gorunur ozellik olcumu
- Iki taramayi karsilastirma
- Cihazda saklanan tarama gecmisi
- Sabah ve aksam rutini olusturucu
- Urun ve makale kutuphanesi
- Turkce ve Ingilizce destegi

Analiz nasil calisir: fotografiniz iPhone'unuzda yuzunuze gore kirpilir, ardindan islenmek uzere guvenli sekilde servisimize gonderilir. Fotograflar tarafimizca kalici olarak saklanmaz. Tarama icin internet baglantisi gerekir; gecmisiniz, profiliniz ve rutininiz cevrimdisi calisir.

Onemli: Skinner kozmetik amacli bir takip aracidir. Teshis koymaz, tedavi onermez ve tibbi tavsiye vermez; dermatolog muayenesinin yerini tutmaz. Cildinizle ilgili bir endiseniz varsa saglik uzmanina basvurun.

**Anahtar Kelimeler:** cilt analizi, cilt bakimi, yuz tarama, cilt takibi, kizariklik, kirisiklik, leke, nem, rutin, guzellik

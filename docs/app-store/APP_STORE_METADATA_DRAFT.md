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

Take a photo with your iPhone camera and Skinner reviews five visible features: breakouts, redness, wrinkles, eye bags, and pigmentation. It then summarises them as three easy-to-follow metrics — hydration, oiliness and inflammation — plus one overall score. Each scan is saved on your device, so you can compare two scans side by side and see what changed.

Key features:
- Five visible-feature readings and three summary metrics from a single photo
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

**12+**. No user-generated content, no social features, no medical claims; the 12+ band covers the "infrequent/mild medical or treatment information" answer that a cosmetic skin-tracking app has to give.

## Support URL

https://keremoztopuz.github.io/skincare-legal/ — sayfa `legal/` altinda hazir, yayinlanmayi bekliyor (`legal/README.md`).

## Marketing URL

TODO: Optional. Leave blank if there is no landing page.

## Privacy Policy URL

https://keremoztopuz.github.io/skincare-legal/privacy — matches `LegalLinks.swift`. The page is written (`legal/privacy/index.html`); publishing the GitHub Pages site is the remaining step.

## Terms of Use URL

https://keremoztopuz.github.io/skincare-legal/terms — a custom page, because `LegalLinks.swift` links to it from every purchase screen. Apple's Standard EULA is the fallback only if that page is not published in time:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## Review Notes

Skinner analyzes visible skin features from a single photo. There is no on-device analysis model.

Processing flow:
1. The user takes a photo with the front camera.
2. The photo is cropped to the detected face on-device using Apple's Vision framework.
3. The crop is sent over HTTPS to our own backend service, which strips image metadata, downscales the image, and forwards it to Google's Gemini API (Vertex AI) for processing.
4. Five visible-feature readings plus a hydration reading are returned; the app shows them alongside three summary metrics and an overall score. The crop is not stored permanently by our service. Google retains requests briefly for abuse monitoring only; they are not used to train models.

No account or sign-in is required. Profile details and scan history are stored only on the device using Core Data and are never uploaded. Product and article content is read from our backend; no user data is sent with those requests.

The app shows a medical disclaimer during onboarding that the user must accept before continuing, and repeats a non-diagnostic notice on every result screen.

Free tier: 5 scans per month, breakouts and redness readings only, last 5 analyses visible. Paid tier unlocks unlimited scans, all five visible-feature readings, full history, and routine recommendations. The three summary metrics and the overall score are free on both tiers.

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

### Weekly

Product ID: `com.keremoztopuz.skincare.pro.monthly` — the identifier is kept and
the plan is sold as a weekly one, so the identifier no longer describes the
period. It is attached to the RevenueCat `$rc_weekly` package of the `default`
offering.

**Open item.** App Store Connect still reports this product's duration as
`ONE_MONTH`. RevenueCat's store-state API accepts a `P1W` duration and reports
the operation as succeeded, but Apple silently drops it — a read-back on
26 August 2026 still returned `ONE_MONTH`. The duration has to be changed in the
App Store Connect UI, or, if the UI locks the field, a new weekly product must
be created and attached to `$rc_weekly` in its place. Until that is done the app
sells a monthly subscription while its paywall reads "per week".

Reference name: Weekly Pro

Display name: Skinner Pro

Description: Unlimited scans, all five visible-feature readings, full scan history, and routine recommendations.

### Lifetime

Product ID: `com.keremoztopuz.skincare.pro.lifetime`, attached to the RevenueCat `$rc_lifetime` package of the `default` offering. Without that package the lifetime card falls back to placeholder pricing.

Reference name: Lifetime Pro

Display name: Skinner Lifetime

Description: One-time purchase. Everything in Pro, with no subscription and no renewal.

### Entitlement

Both products must unlock the RevenueCat entitlement `skanner_pro`. The app treats this entitlement as the single source of premium status, so a product that is not attached to it takes the user's money without unlocking anything.

### Pricing

The app's placeholder prices — shown only until StoreKit returns the real storefront price — are:

| Storefront | Weekly | Lifetime |
| --- | --- | --- |
| US | $3.99 | $12.99 |
| EU | €3,99 | €14,99 |
| TR | ₺99,99 | ₺699,99 |

The subscription became weekly on 26 August 2026 at the same US and EU amounts
it carried as a monthly plan, with TR set back to ₺99,99. The three storefronts
above were set by hand rather than equalized from a base territory, so each of
the three is its own decision — and the remaining territories still sit on the
old $1.99 base until someone equalizes them from US in App Store Connect.

The lifetime product could not be equalized through RevenueCat — its equalize
endpoint rejects non-consumables — so its non-TR tiers were set by hand in App
Store Connect. The table above is the live App Store Connect state as read back
on 26 August 2026; `SubscriptionManager.FallbackPrice` matches it. TR ₺699,99
is still roughly 7x the weekly while US $12.99 is roughly 3.3x, so the two
storefronts are not a strict multiple of each other. Change a tier in App Store
Connect and this table and the fallback both have to move with it.

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

iPhone kameranizla bir fotograf cekin; Skinner bes gorunur ozelligi degerlendirir: sivilce, kizariklik, kirisiklik, goz alti torbalari ve leke. Ardindan bunlari uc anlasilir metrige (nem, yaglilik, iltihaplanma) ve tek bir genel skora ozetler. Her tarama cihazinizda saklanir, boylece iki taramayi yan yana karsilastirip neyin degistigini gorebilirsiniz.

Ozellikler:
- Tek fotograftan bes gorunur ozellik olcumu ve uc ozet metrik
- Iki taramayi karsilastirma
- Cihazda saklanan tarama gecmisi
- Sabah ve aksam rutini olusturucu
- Urun ve makale kutuphanesi
- Turkce ve Ingilizce destegi

Analiz nasil calisir: fotografiniz iPhone'unuzda yuzunuze gore kirpilir, ardindan islenmek uzere guvenli sekilde servisimize gonderilir. Fotograflar tarafimizca kalici olarak saklanmaz. Tarama icin internet baglantisi gerekir; gecmisiniz, profiliniz ve rutininiz cevrimdisi calisir.

Onemli: Skinner kozmetik amacli bir takip aracidir. Teshis koymaz, tedavi onermez ve tibbi tavsiye vermez; dermatolog muayenesinin yerini tutmaz. Cildinizle ilgili bir endiseniz varsa saglik uzmanina basvurun.

**Anahtar Kelimeler:** cilt analizi, cilt bakimi, yuz tarama, cilt takibi, kizariklik, kirisiklik, leke, nem, rutin, guzellik

# SkinCareAI — CLAUDE.md

## Working Style
- Kullanici "yap", "yaz", "ekle", "go" gibi acik komut vermedikce KOD YAZMA
- "Anlat", "acikla", "nasil yapicam" gibi ifadelerde sadece adim adim acikla
- Kullanici kodu kendisi yazmak ve ogrenmek istiyor — hayatinda hic SwiftUI yazmamis birisine anlatir gibi acikla
- Kullanici onayi olmadan dosya olusturma, duzenleme yapma
- **Her islem oncesi dosyanin guncel halini oku** — aciklama veya degisiklik yapmadan once mutlaka dosyaya girip son durumu kontrol et
- **Commit mesajlarında "co-authorized by Gemini", "Claude", "Codex" gibi ifadeler ASLA kullanma**
- **Mimari Karar:** Projede `ObservableObject` ve `@Published` kullanılacaktır. Kod yapısını modernize etmek yerine stabiliteye odaklanılacaktır.

## Project Overview
- **App:** SkinCareAI — iOS SwiftUI cilt analizi uygulamasi (senior design project, CENG495)
- **Team:** Berat Kerem Ozttopuz + Zeynep Aslan
- **Min iOS:** 18.0+
- **Pattern:** MVVM

## App Flow
Splash (4.5s) → OnBoarding (4 pages) → Profile Setup → Loading (3.5s) → Subscription → Loading (3.5s) → Main App

## AppState (ContentViewModel)
```
.splash → .onboarding → .profileSetup → .subscription → .loading → .mainApp
```
- `showSplash = true` → 4.5s sonra false olur
- `@Published var hasCompletedOnBoarding`, `hasCompletedProfile`, `hasCompletedSubscription` ve `isPremium` bayrakları ile yönetiliyor.
- Tüm bayraklar `UserDefaults` (didSet) ile kalıcı hale getirilmiştir.
- Kullanıcı OnBoarding, Profile ve Subscription adımlarını bir kez görür.

## Color Palette
- **Primary (buttons, accents):** rgb(0.47, 0.11, 0.17) = #781A2B (dark burgundy/maroon)
- **Background:** rgb(1.0, 0.97, 0.97) = #FFF7F7 (very light pink)
- **Outer ring (icon bg):** rgb(1.0, 0.87, 0.87) = #FFDFDF (soft pink)
- **Card bg:** white
- **Primary text:** rgb(0.1, 0.1, 0.2) near-black

## Animation Style
- Spring pop-up animasyonlari: `.spring(response: 0.4, dampingFraction: 0.6)`
- Elemanlar sirayla belirir (staggered): logo → title → description (delay 0.08-0.14sn arasi)
- `scaleEffect(0)` → `scaleEffect(1.0)` ile pop-up efekti
- Dis daire (pembe) pulsing: `.easeInOut(duration: 1.4).repeatForever(autoreverses: true)` ile 1.0-1.12 arasi nefes efekti
- Ic ice daireler (pembe dis + bordo ic + beyaz ikon) signature tasarim elementi

## Persistence (Core Data)
- **LocalPersistenceManager:** Singleton, UserProfile ve AnalysisRecord tabloları.
- **Profil Fetch Kuralı:** Birden fazla profil kaydı oluşma ihtimaline karşı her zaman `createdAt` tarihine göre azalan sıralama yapılıp en yeni kayıt çekilir (`fetchLimit = 1`).

## Tab Bar Screens (5 tabs)
- **Home:** Saat bazlı selamlama (Good Morning/Afternoon/Evening/Night), 2x2 istatistik kartları, Öneriler.
- **Search:** Search bar + Dermatological Products with rating badges.
- **Camera:** Scan Your Face — camera preview + capture button.
- **Recents:** Recent Analyses list, score + trend, progress bars.
- **More:** Subscription status + Settings.

## Analysis Architecture (dual-engine, fully on-device)
### CoreML — skin_disease.mlpackage
- 3 classes: acne, eczema, psoriasis
- Confidence threshold < 50% → "Cildiniz saglikli gorunuyor"

### Apple Vision Framework + CoreImage
- Wrinkle detection → VNFaceLandmarks2D + Sobel filter
- Under-eye bag detection → landmark crop + color/contour analysis

### Subscription-based feature gating
- `isPremium` bayrağına göre özellikler kısıtlanır (Psoriasis, Wrinkle, Eyebag analizleri Premium'a özeldir).

## Data & Privacy
- **Core Data:** all user data (profile, analysis history) — NEVER leaves device.
- **Supabase (PostgreSQL):** articles, product recommendations, nutrition tips (fetch only).
- **Privacy-by-design:** ALL biometric/face data stays on device, no images leave the device EVER.
- **Offline-first:** CoreML, Vision, scoring, history, profile all work without internet.
- **Online required only for:** Supabase content → show "Internet baglantisi gerekli" when offline.

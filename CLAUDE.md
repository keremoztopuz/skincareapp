# SkinCareAI — CLAUDE.md

## Working Style
- Kullanici "yap", "yaz", "ekle", "go" gibi acik komut vermedikce KOD YAZMA
- "Anlat", "acikla", "nasil yapicam" gibi ifadelerde sadece adim adim acikla
- Kullanici kodu kendisi yazmak ve ogrenmek istiyor — hayatinda hic SwiftUI yazmamis birisine anlatir gibi acikla
- Kullanici onayi olmadan dosya olusturma, duzenleme yapma
- **Commit mesajlarında "co-authorized by Gemini", "Claude", "Codex" gibi ifadeler ASLA kullanma**

## Project Overview
- **App:** SkinCareAI — iOS SwiftUI cilt analizi uygulamasi (senior design project, CENG495)
- **Team:** Berat Kerem Ozttopuz + Zeynep Aslan
- **Min iOS:** 18.0+
- **Pattern:** MVVM

## App Flow
Splash (2sn) → OnBoarding (4 pages) → Profile Setup (Name→Age→Gender→SkinType) → Subscription → Main App (Tab Bar)

## AppState (ContentViewModel)
```
.splash → .onboarding → .profileSetup → .mainApp
```
- `showSplash = true` → 2sn sonra false olur
- `@AppStorage("hasCompletedOnBoarding")` ve `@AppStorage("hasCompletedProfile")` ile yonetiliyor
- Kullanici OnBoarding ve ProfileSetup'i bir kez gorur

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

## File Structure
```
SkinCare/
├── App/
│   └── SkinCareApp.swift
├── Model/
│   ├── Articles.swift
│   ├── Gender.swift
│   ├── OnBoardingPage.swift
│   ├── SkinCondition.swift
│   ├── SkinType.swift
│   └── UserProgress.swift
├── View/
│   ├── AnalysisView.swift
│   ├── CameraView.swift
│   ├── ContentView.swift         ← AppState switch (splash/onboarding/profileSetup/mainApp)
│   ├── HomeView.swift
│   ├── MainTabView.swift          ← 5 tab bar
│   ├── MoreView.swift
│   ├── OnBoardingView.swift       ← DONE (4 pages, Lottie + spring animations)
│   ├── ProfileSetupView.swift
│   ├── ProfileView.swift
│   ├── RecentsView.swift
│   ├── ResultView.swift
│   ├── SearchView.swift
│   └── SplashView.swift           ← DONE (logo circles, pop-up + pulsing animations, tips)
├── ViewModel/
│   ├── ContentViewModel.swift     ← AppState, splash timer, UserDefaults observer
│   ├── HomeViewModel.swift
│   ├── OnBoardingViewModel.swift
│   ├── ProfileSetupViewModel.swift
│   └── SkinAnalysisViewModel.swift
├── Services/
│   ├── LocalPersistenceManager.swift  ← singleton, Core Data
│   ├── Persistence.swift
│   └── ScoringEngine.swift
└── Resources/
    └── MLManager.swift
```

## Tab Bar Screens (5 tabs)
- **Home:** Greeting, Skin Analysis CTA, 2x2 stats grid, Recommendations
- **Search:** Search bar + Dermatological Products with rating badges
- **Camera:** Scan Your Face — camera preview + capture button
- **Recents:** Recent Analyses list, score + trend, progress bars
- **More:** Subscription plans (Free/$0, Premium/$9.99, Professional/$19.99) + rating

## Analysis Architecture (dual-engine, fully on-device)
### CoreML — skin_disease.mlpackage
- 3 classes: acne, eczema, psoriasis
- Confidence threshold < 50% → "Cildiniz saglikli gorunuyor"

### Apple Vision Framework + CoreImage
- Wrinkle detection → VNFaceLandmarks2D + Sobel filter
- Under-eye bag detection → landmark crop + color/contour analysis

### Subscription-based feature gating
| Feature | Free | Premium/Pro |
|---|---|---|
| Acne detection | YES | YES |
| Eczema detection | YES | YES |
| Psoriasis detection | NO | YES |
| Wrinkle analysis | NO | YES |
| Under-eye bags | NO | YES |

## Data & Privacy
- **Core Data:** all user data (profile, analysis history) — NEVER leaves device
- **Supabase (PostgreSQL):** articles, product recommendations, nutrition tips (fetch only)
- **Privacy-by-design:** ALL biometric/face data stays on device, no images leave the device EVER
- **Offline-first:** CoreML, Vision, scoring, history, profile all work without internet
- **Online required only for:** Supabase content → show "Internet baglantisi gerekli" when offline

## Key Differentiators (vs competitors like Skan)
- Tamamen offline analiz — internet olmadan da calisir
- Fotograflar cihazda kalir — gercek privacy-by-design
- Dual-engine (CoreML + Vision) — on-device

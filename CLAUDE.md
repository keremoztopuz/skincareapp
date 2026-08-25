# SkinCare — Development Guide

## Working Style
- Do not write code unless explicitly asked
- Explain step by step for learning
- Read file content before making changes
- **Git Workflow:** Each file change must have its own commit and message.
- **Commit Messages:** Do not use any automated authoring tool mentions.

## Project Overview
- **App:** Skinner — iOS SwiftUI skin analysis app (Xcode project/target and bundle ID are still named SkinCare)
- **Team:** Berat Kerem Ozttopuz + Zeynep Aslan
- **Min iOS:** 18.0+
- **Pattern:** MVVM

## App Flow
Splash (4.5s) → OnBoarding (4 pages) → Profile Setup → Loading (3.5s) → Subscription → Loading (3.5s) → Main App

## AppState (ContentViewModel)
```
.splash → .onboarding → .profileSetup → .subscription → .loading → .mainApp
```
- `showSplash = true` → false after 4.5s
- Managed with `@Published var hasCompletedOnBoarding`, `hasCompletedProfile`, `hasCompletedSubscription`, and `isPremium` flags.
- All flags are persisted via `UserDefaults` (didSet).
- User sees OnBoarding, Profile, and Subscription steps once.

## Color Palette
- **Primary (buttons, accents):** rgb(0.47, 0.11, 0.17) = #781A2B (dark burgundy/maroon)
- **Background:** rgb(1.0, 0.97, 0.97) = #FFF7F7 (very light pink)
- **Outer ring (icon bg):** rgb(1.0, 0.87, 0.87) = #FFDFDF (soft pink)
- **Card bg:** white
- **Primary text:** rgb(0.1, 0.1, 0.2) near-black

## Animation Style
- Spring pop-up animations: `.spring(response: 0.4, dampingFraction: 0.6)`
- Elements appear in sequence (staggered): logo → title → description (delay between 0.08-0.14s)
- Pop-up effect with `scaleEffect(0)` → `scaleEffect(1.0)`
- Outer circle (pink) pulsing: breathing effect between 1.0-1.12 with `.easeInOut(duration: 1.4).repeatForever(autoreverses: true)`
- Nested circles (pink outer + burgundy inner + white icon) signature design element

## Persistence (Core Data)
- **LocalPersistenceManager:** Singleton, UserProfile and AnalysisRecord tables.
- **Profile Fetch Rule:** In case of multiple profile records, the most recent record is always fetched by sorting descending by `createdAt` (`fetchLimit = 1`).

## Tab Bar Screens (5 tabs)
- **Home:** Time-based greeting (Good Morning/Afternoon/Evening/Night), 2x2 statistics cards, Recommendations.
- **Search:** Search bar + Dermatological Products catalog.
- **Camera:** Scan Your Face — camera preview + capture button.
- **Recents:** Recent Analyses list, score + trend, progress bars.
- **More:** Subscription status + Settings.

## Analysis Architecture (cloud)
- **All six metrics** (breakouts/acne, redness, wrinkles, eyebags, pigmentation, hydration) come from **Gemini 2.5 Flash on Vertex AI**, called through a FastAPI proxy (`~/Desktop/skincare-proxy/`, outside this repo).
- The app holds no cloud credential. `AnalysisConfig.swift` (gitignored) carries only the proxy URL and a shared client token.
- Face detection and cropping stay on-device (Vision); the crop is JPEG-encoded and sent to the proxy, which strips EXIF, downscales to 768px, enforces rate limits and a daily spend ceiling.
- There is **no on-device model** and **no offline analysis**. A failed network call must never persist a record or burn a scan (`didProduceModelScores` guard in `CameraViewModel.buildRecord`).

## Data & Privacy
- **Core Data:** all user data (profile, analysis history) — stays on device.
- **Supabase (PostgreSQL):** articles, product recommendations, routine content (fetch only).
- **Privacy-by-design:** Face crops are sent securely to the analysis proxy (Vertex AI / Gemini) for real-time processing and are not stored permanently by our services. Google retains requests briefly for abuse monitoring; they are not used to train models.
- **Connectivity:** Analysis requires an internet connection. History, profile and routines work offline.

# Skinner — Development Guide

## Working Style
- Do not write code unless explicitly asked
- Explain step by step for learning
- Read file content before making changes
- **Git Workflow:** Each file change must have its own commit and message.
- **Commit Messages:** Do not use any automated authoring tool mentions.
- **Logging:** No `print` or `NSLog` in app code. Everything goes through `AppLog` (`App/AppLog.swift`), which redacts interpolated values in device logs.
- **Error copy:** Never report a backend fault as a connection problem. Use `AppStrings.loadFailureMessage(for:)`, which only says "check your internet" for a real `URLError`.

## Project Overview
- **App:** Skinner — iOS SwiftUI skin analysis app (Xcode project/target and bundle ID are still named SkinCare)
- **Maintainer:** Berat Kerem Öztopuz
- **Min iOS:** 18.0+
- **Pattern:** MVVM

## App Flow
Splash (4.5s) → OnBoarding (4 pages) → Disclaimer → Profile Setup → Loading (1.5s) → Subscription → Loading (1.5s) → Main App

## AppState (ContentViewModel)
```
.splash → .onboarding → .disclaimer → .profileSetup → .loading → .subscription → .loading → .mainApp
```
- `currentState` is computed, not assigned: it resolves the first unmet step in the order above, so the flags are the only state.
- `showSplash = true` → false after 4.5s; `showLoading` gates each 1.5s pause.
- Flags: `hasCompletedOnBoarding`, `hasAcceptedDisclaimer`, `hasCompletedProfile`, `hasCompletedSubscription`, plus `isPremium` on `SubscriptionManager`.
- All flags are persisted via `UserDefaults` (didSet).
- User sees OnBoarding, Disclaimer, Profile, and Subscription steps once.

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
- **Home:** Time-based greeting (Good Morning/Afternoon/Evening/Night), 2x2 statistics cards, routine summary, Recommendations.
- **Search:** Search bar + Dermatological Products catalog.
- **Camera:** Scan Your Face — camera preview + capture button.
- **Recents:** Recent Analyses list, score + trend, progress bars.
- **More:** Subscription status + Settings.

Not a tab: **Routine** (`RoutineView`) is pushed from Home and from a finished analysis; **Compare**, **Detail** and **Result** are likewise pushed, not tabbed.

## Analysis Architecture (cloud)

**5 classes + 3 metrics + 1 overall score.** Keep this split straight — the class
names and the metric names are deliberately different vocabularies.

| Layer | Values | Where it comes from |
|---|---|---|
| **5 classes** — the measured conditions, shown as bars on `ResultView` | `acne`, `redness`, `wrinkles`, `eyebags`, `pigmentation` | Returned by the model, 0-100, **higher = worse** |
| **3 metrics** — the summary cards on Home, `RecordCard`, `CompareView` | **Hydration**, Oiliness, Inflammation | Hydration is returned by the model (**higher = better**, the only inverted score). Oiliness and inflammation are derived in `ScoringEngine` from the classes plus the self-reported skin type |
| **1 overall score** | `overallScore` | `ScoringEngine`, `100 * exp(-load)` over the five classes plus the hydration load |

- Strings follow the split: `condition_*` keys name classes, `metric_*` keys name metrics.
- `ResultView` bars are paywalled: acne and redness free, wrinkles/eyebags/pigmentation Pro. The three metrics are free.
- Core Data note: `eczemaScore` holds **redness** — a legacy column name, not a separate condition.
- Changing a formula means bumping `currentVersion` in `LocalPersistenceManager.migrateScoresIfNeeded()`, or old records stay on the old scale and the trend chart shows a phantom jump.
- All six model outputs come from **Gemini 2.5 Flash on Vertex AI**, called through a FastAPI proxy (`~/Desktop/skincare-proxy/`, outside this repo).
- The app holds no cloud credential. `AnalysisConfig.swift` (gitignored) carries only the proxy URL and a shared client token.
- Face detection and cropping stay on-device (Vision); the crop is JPEG-encoded and sent to the proxy, which strips EXIF, downscales to 768px, enforces rate limits and a daily spend ceiling.
- There is **no on-device model** and **no offline analysis**. A failed network call must never persist a record or burn a scan (`didProduceModelScores` guard in `CameraViewModel.buildRecord`).

## Data & Privacy
- **Core Data:** all user data (profile, analysis history) — stays on device.
- **Supabase (PostgreSQL):** articles, product recommendations, routine content (fetch only).
- **Privacy-by-design:** Face crops are sent securely to the analysis proxy (Vertex AI / Gemini) for real-time processing and are not stored permanently by our services. Google retains requests briefly for abuse monitoring; they are not used to train models.
- **Connectivity:** Analysis requires an internet connection. History, profile and routines work offline.

## Known Limitation — Supabase catalogue
`supabase/seed/00_schema.sql` has never been run against the live project, so
`description_tr` / `title_tr` / `content_tr` do not exist there and every list
query returns HTTP 400. Home and Search therefore show the "content can't be
loaded" state rather than a catalogue. This is deliberate for now: the backend
moves to Vertex/Firestore next, and the seed will be revisited there.

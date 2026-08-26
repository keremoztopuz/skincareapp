# Skinner Graduation Pitch Memory

> Architecture note (26 Aug 2026): the on-device CoreML phase is **retired**.
> The shipped system runs analysis in the cloud. Sections 6-13 below describe
> the current system; the ConvNeXt prototype is kept only as the superseded
> earlier phase, clearly labelled as such.

This file is the working memory for preparing the Computer Engineering Graduation Project pitch deck.

## Required Presentation Intent

The presentation must not be a pure technical report. It must work as:

- Pitch
- Engineering proof
- Technical validation

The jury should be convinced that:

- The problem is worth solving.
- The proposed solution is meaningful.
- Real engineering work has been done.
- The system actually works.
- The team understands the technology and design decisions.

Recommended formula:

Problem -> Solution -> Demo -> Architecture -> Technical Decisions -> Validation -> Results -> Conclusion

## Required Slide Flow

1. Title
   - Project name
   - Student names
   - Supervisor
   - University
   - Department
   - Date

2. Problem Statement
   - Explain the real-world problem.
   - Skinner angle: limited dermatology access, missed early symptoms, users struggle to understand skin conditions.

3. Proposed Solution
   - One simple sentence.
   - Suggested wording: AI-powered mobile skin analysis app that analyzes user photos and provides preliminary condition assessment and care recommendations.

4. Live Demo / Product Walkthrough
   - Show the system early.
   - Flow: open app -> take photo -> AI analyzes image -> results displayed.
   - If live demo is risky, use screenshots or screen recording.

5. Existing Solutions and Literature Review
   - Concise comparison table.
   - Compare studies/products by strengths and limitations.
   - Position our project as mobile + AI + academic prototype.

6. System Architecture
   - High-level only.
   - Architecture: User -> Swift iOS App -> on-device face crop (Vision) -> FastAPI proxy (Cloud Run) -> Gemini 2.5 Flash on Vertex AI -> scores back to the app -> Core Data (local history) + Supabase (catalogue content).
   - The app holds no cloud credential; the proxy owns the Vertex key, strips EXIF, downscales, rate-limits and enforces a daily spend ceiling.

7. Technology Stack
   - SwiftUI: iOS user interface.
   - Vision: on-device face detection and cropping.
   - FastAPI on Cloud Run: the analysis proxy, written in Python.
   - Gemini 2.5 Flash on Vertex AI: the analysis model.
   - Core Data: local profile and scan history.
   - Supabase (PostgreSQL): product catalogue, articles, routine content (read-only).
   - RevenueCat + StoreKit 2: subscriptions.
   - Earlier phase (retired): PyTorch + timm ConvNeXt Tiny, exported to CoreML.

8. Core Engineering Design
   - Explain technical decisions and why they were selected.
   - Decision: move inference off the device. The 5-class ConvNeXt prototype capped out at 75% accuracy on a small dataset; a hosted vision-language model covers more visible features with better generalisation, and can be improved without shipping an app update.
   - Decision: keep face detection and cropping on-device. Only the face crop leaves the phone, never the full photo.
   - Decision: put a proxy between app and Vertex. The app cannot hold a cloud credential, and the proxy is where rate limiting, EXIF stripping and the spend ceiling live.
   - Decision: a failed network call must never persist a record or burn a scan (`didProduceModelScores` guard).
   - Decision: the second class is called Redness in the UI, not Eczema — a cosmetic-feature name, not a clinical one. Core Data still stores it in the legacy `eczemaScore` column.

9. AI / Algorithm Design
   - Model: Gemini 2.5 Flash on Vertex AI, called with a constrained JSON response schema so the output is always six bare numbers.
   - Input: a 768px face crop, JPEG, EXIF stripped by the proxy.
   - **5 measured classes** (0-100, higher = worse): acne, redness, wrinkles, eyebags, pigmentation.
   - Plus one **hydration** reading (0-100, higher = better) — the only inverted score, stated twice in the prompt because a language model quietly flips it otherwise.
   - **3 metrics shown to the user**: hydration (measured), oiliness and inflammation (derived in `ScoringEngine` from the classes plus the self-reported skin type).
   - **1 overall score**: `100 * exp(-load)` over the weighted classes plus the hydration load. Exponential soft saturation rather than a linear sum with a hard cap, so the full 0-100 range stays usable.
   - Superseded prototype (present as history, not as the current system): ConvNeXt Tiny via timm, 384x384, 5 classes (Acne, Redness, Psoriasis, Eye_Bags, Wrinkles), batch 32, lr 5e-5, weight decay 0.1, label smoothing 0.1, class weights [1.0, 1.0, 1.0, 2.03, 4.23].

10. Database and Data Model
   - Keep high level.
   - Main entities: AnalysisRecord, UserProfile, RoutineItem, RoutineSuggestion.
   - AnalysisRecord stores the five class scores, the hydration reading, the two derived metrics, the overall score, condition, date and image data.
   - Formula changes are versioned: `migrateScoresIfNeeded()` recomputes stored history so the trend chart stays comparable.

11. Testing and Validation
   - Functional tests to mention:
     - Camera capture
     - On-device face detection and cropping
     - Proxy request/response, including auth, rate limit and error shapes
     - Score migration across formula versions
     - Result display
     - Analysis record persistence
     - Recommendation/routine generation
     - Localization key parity (EN/TR)
   - 22 automated tests, all passing.
   - Retired prototype's metrics — present these as *why we moved to the cloud*, not as validation of the shipped system:
     - Accuracy: 75.02%, Precision: 0.6818, Recall: 0.6012, F1: 0.5846
     - Plots live in the separate training repo (`~/Desktop/senior_design_project_ai_model`), not in this one.

12. Challenges and Solutions
   - Dataset limitations and class imbalance capped the on-device model; Eye_Bags and Wrinkles never reached usable recall. Solution: move to a hosted vision-language model.
   - A cloud model means a credential the app cannot hold. Solution: a proxy that owns the key and enforces rate limits and a daily spend ceiling.
   - A language model silently flips an inverted scale. Solution: state the hydration inversion in both the prompt and the response schema, and validate ranges server-side.
   - A failed request must not cost the user a scan. Solution: persist and decrement quota only after a verified result.
   - Changing a scoring formula breaks comparability with old scans. Solution: a versioned migration that recomputes history.

13. Contributions and Achievements
   - End-to-end working iOS app, not a prototype: onboarding, analysis, history, comparison, routine, subscriptions.
   - Custom trained skin condition model (earlier phase) and the engineering judgement to retire it.
   - Cloud analysis pipeline with its own authenticated proxy service.
   - Derived scoring engine with versioned migration.
   - Recommendation and routine generation from analysis results.
   - Bilingual (EN/TR) app with enforced key parity.

14. Future Improvements
   - Move the content backend from Supabase to Vertex/Firestore.
   - Calibrate the model's readings against labelled examples.
   - Add doctor verification workflow.
   - Add more skin condition categories.
   - Improve confidence calibration and threshold tuning.
   - More robust real-world testing.

15. Conclusion
   - Summarize problem, solution, working system, and achieved objectives.
   - Suggested wording: The proposed mobile AI system successfully performs preliminary skin condition assessment and demonstrates the feasibility of real-time AI-assisted skincare analysis.

16. Questions
   - Thank you / Q&A.

## Current Technical Notes

- There is **no** model file, `MLManager.swift` or `SkinCondition.swift` in the repo any more; they were deleted with the CoreML phase.
- Swift files involved in analysis:
  - `SkinCare/ViewModel/CameraViewModel.swift` — capture, face crop, error mapping, persistence guard
  - `SkinCare/Services/AnalysisService.swift` — proxy call and response decoding
  - `SkinCare/Services/ScoringEngine.swift` — derived metrics and overall score
- Proxy lives outside this repo at `~/Desktop/skincare-proxy` (FastAPI, deployed to Cloud Run).
- The retired training work lives in `~/Desktop/senior_design_project_ai_model`.

## Deck Guidance

- Start with the problem, not CNN details.
- Show the working app early.
- Use screenshots or screen recording if live demo is risky.
- Keep architecture high level.
- Use the architecture diagram and the migration story as engineering proof; the old confusion matrices belong in the "why we changed approach" slide, not the validation slide.
- Be honest about limitations: readings are estimates from one photo, sensitive to lighting and angle, and the app makes no medical claim.

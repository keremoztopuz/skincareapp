# App Store Metadata Draft

Bu taslak App Store Connect'e kopyalanmadan once son urun kararlarina gore kontrol edilmelidir.

## App Name

SkinCare

## Subtitle

Personal skin analysis and routine tracker

## Promotional Text

Understand visible skin concerns, track your progress, and build a simple skincare routine from your iPhone.

## Description

SkinCare helps you review visible skin concerns, track your analysis history, and organize a personal skincare routine.

Use your iPhone camera to run an on-device skin analysis for visible concerns such as acne, redness, wrinkles, under-eye appearance, pigmentation, and hydration-related signals. Your scan history stays on your device, so you can compare changes over time and follow your progress.

The app also includes product discovery, skincare articles, and routine suggestions powered by curated content.

Key features:
- On-device skin analysis
- Local scan history and progress tracking
- Personalized routine builder
- Product and article discovery
- Free monthly scans with optional Pro subscription
- Privacy-focused design: face images are not uploaded for analysis

Important: SkinCare does not provide medical diagnosis, treatment, or professional medical advice. Results are for informational and cosmetic tracking purposes only. Consult a qualified healthcare professional for medical concerns.

## Keywords

skincare, skin analysis, acne, redness, routine, beauty, face scan, skin tracker, products, hydration

## Category

Primary: Health & Fitness

Alternative: Lifestyle

## Support URL

TODO: Add public support page URL.

## Privacy Policy URL

TODO: Publish `PRIVACY_POLICY_DRAFT.md` as a public web page and add its URL.

## Terms of Use URL

Use Apple's Standard EULA if there is no custom terms page:
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

## Review Notes

SkinCare performs face and skin analysis on device. Captured face images are not uploaded to our servers for analysis.

Supabase is used only to fetch skincare articles, product catalog data, and routine recommendation content. User face images and biometric data are not sent to Supabase.

The app includes a clear medical disclaimer during onboarding. The app does not claim to diagnose or treat medical conditions.

Subscription testing:
- Pro entitlement name: `pro`
- Monthly product ID: `skincare_pro_monthly`
- Restore Purchases is available on the subscription screen.

If the reviewer needs access beyond the free scan limit, use a sandbox subscription purchase or ask us through App Review notes.

## App Privacy Draft

Confirm these answers against the final implementation before submitting.

Data collected by the app:
- User profile data: name, age range, gender, skin type, known issues. Stored on device.
- Photos or videos: camera image used for local analysis and local scan history. Not uploaded for analysis.
- Purchase data: handled by Apple and RevenueCat for subscription status.
- Product interaction/routine data: routine selections and analysis history stored on device.

Data linked to the user:
- Purchases may be linked by Apple/RevenueCat.
- Local profile and scan history remain on device unless future sync is added.

Tracking:
- No third-party advertising tracking should be enabled.

Data used for tracking:
- None, unless future analytics/ads are added.

Sensitive data:
- Face/skin images are processed locally. Treat as sensitive in the privacy answer and description.

## Subscription Metadata

Product ID:
`skincare_pro_monthly`

Reference name:
Monthly Pro

Display name:
SkinCare Pro

Suggested description:
Unlock unlimited monthly skin analyses, advanced visible-skin metrics, full scan history, and routine recommendations.

Price:
TODO: Decide final App Store Connect price. Current UI references `$4.99/month`; local StoreKit file references `9.99`. These must match before review.

Introductory offer:
TODO: If keeping "3-day free trial" in UI, configure the same 3-day free trial in App Store Connect.

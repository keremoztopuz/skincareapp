# Privacy Policy Draft

Effective date: TODO

SkinCare is designed to help users review visible skin concerns, track their skincare progress, and organize skincare routines.

This draft must be published on a public URL before App Store submission.

## Information We Process

SkinCare may process the following information:

- Profile information you enter, such as name, age range, gender, skin type, and known skin concerns.
- Camera images captured for skin analysis.
- Local analysis results, scan history, scores, and routine selections.
- Subscription status and purchase information handled through Apple and RevenueCat.
- Product and article content fetched from Supabase.

## Hybrid Skin Analysis

SkinCare uses a hybrid approach to analyze visible skin concerns:
- **On-Device Analysis:** Initial face detection and basic condition analysis (acne, redness) are performed entirely on your device using Apple's CoreML and Vision frameworks.
- **Cloud Analysis:** Advanced cosmetic metrics (wrinkles, eyebags, pigmentation, and hydration) are analyzed using Google Gemini API (Cloud VLM). This requires an active internet connection and transmits securely cropped face images for real-time analysis.

Face and skin images captured for analysis are processed in real-time and are not stored permanently by our services or by Google Gemini for any purpose other than providing the immediate results requested.

Scan images and analysis results (scores and dates) are saved locally on your device so you can review previous results. You can remove local history from within the app if deletion controls are available, or by deleting the app from your device.

## Online Content

SkinCare may connect to Supabase to fetch:

- Skincare articles
- Product catalog information
- Product recommendations
- Routine-related content

These requests are used to display app content. SkinCare should not send captured face images to Supabase.

## Purchases and Subscriptions

SkinCare may offer optional paid subscriptions. Purchases are processed by Apple. Subscription status may be checked through RevenueCat so the app can unlock paid features.

We do not receive your full payment card information.

## Medical Disclaimer

SkinCare does not provide medical diagnosis, medical treatment, or professional medical advice. Analysis results are for informational and cosmetic tracking purposes only.

If you have a medical concern, skin disease, pain, rapidly changing symptoms, or an urgent health issue, consult a qualified healthcare professional.

## Data Sharing

We do not sell your personal information.

We may use service providers only where needed to operate the app, such as Apple for purchases, RevenueCat for subscription status, and Supabase for app content.

## Data Retention

Local profile, scan history, and routine data may remain on your device until you delete it in the app or uninstall the app.

Subscription records are retained by Apple and RevenueCat according to their policies.

## Children's Privacy

SkinCare is not intended for children under 13. If you believe a child has provided personal information, contact us so we can help address the issue.

## Your Choices

You can:

- Decline camera access, though analysis features will not work.
- Delete local app data by deleting the app from your device.
- Manage or cancel subscriptions in your Apple Account settings.
- Contact support for privacy questions.

## Contact

Support email: TODO

Support URL: TODO

Privacy contact: TODO

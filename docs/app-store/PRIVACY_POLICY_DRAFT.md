# Privacy Policy Draft

Effective date: 7 September 2026

Skinner is designed to help users review visible skin features, track changes over time, and organize skincare routines.

Published at https://keremoztopuz.github.io/skincare-legal/privacy — the same URL the app links to from every purchase screen.

## Information We Process

Skinner may process the following information:

- Profile information you enter, such as name, age, gender, and skin type.
- Camera images captured for analysis.
- Analysis results, scan history, scores, and routine selections, stored on your device.
- Subscription status and purchase information handled through Apple and RevenueCat.
- Product and article content fetched from our backend service.

## How Analysis Works

Skin analysis runs in the cloud. There is no analysis model on your device.

1. Before analysis, the app requests explicit permission to share your face crop, age and skin type with our backend and Google Gemini on Vertex AI. Declining leaves local history and routines available.
2. Your device detects and crops one face using Apple's Vision framework. If this fails or multiple faces are found, no photo is sent. With permission, the crop, age and skin type are sent over HTTPS to our service and then Vertex AI. Name and gender are not transmitted.
3. The service returns numeric readings for five visible features — breakouts, redness, wrinkles, eye bags, and pigmentation — plus a hydration reading. The app then presents three summary metrics (hydration, oiliness and inflammation) and one overall score. All of it is shown to you and saved on your device.

An internet connection is required to run an analysis. Your history, profile, and routine remain available offline.

Images sent for analysis are not stored permanently by us. Google may retain request data for abuse monitoring and temporary caching under its [Vertex AI policies](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/vertex-ai-zero-data-retention). Google does not train its models on customer data without prior permission or instruction. Images are never used for advertising and are never sold.

Scan images and results are saved locally on your device so you can review previous results. You can delete this data from within the app, or by deleting the app from your device.

## Online Content

Skinner connects to our backend service to fetch product catalog information, product recommendations, articles, and routine-related content.

These requests are used only to display app content. No captured images and no profile information are sent with them.

## Purchases and Subscriptions

Skinner offers optional paid purchases. Purchases are processed by Apple. Subscription and purchase status is checked through RevenueCat so the app can unlock paid features. RevenueCat assigns an anonymous identifier for this purpose; it is not linked to your name or profile.

We do not receive your full payment card information.

## Medical Disclaimer

Skinner does not provide medical diagnosis, medical treatment, or professional medical advice. Results describe visible cosmetic features only and are for informational and tracking purposes.

If you have a medical concern, a skin condition, pain, rapidly changing symptoms, or an urgent health issue, consult a qualified healthcare professional.

## Data Sharing

We do not sell your personal information.

We use service providers only where needed to operate the app:

- **Apple** — purchase processing.
- **RevenueCat** — subscription and purchase status.
- **Google (Gemini / Vertex AI)** — image processing for analysis, through our backend service.

## Data Retention

Profile, scan history, and routine data remain on your device until you delete them in the app or uninstall the app.

Images sent for analysis are not retained by us after the result is returned.

Subscription records are retained by Apple and RevenueCat according to their policies.

## Children's Privacy

Skinner is not intended for children under 13. If you believe a child has provided personal information, contact us so we can help address the issue.

## Your Choices

You can:

- Decline camera access, though analysis will not work without it.
- Decline AI sharing permission or withdraw it in Settings before future scans. Withdrawal does not undo processing of an already-sent request.
- Delete your local data from within the app, or by deleting the app from your device.
- Manage or cancel subscriptions in your Apple Account settings.
- Contact support for privacy questions.

## Contact

Support email: keremoztopuzzz@gmail.com

Support URL: https://keremoztopuz.github.io/skincare-legal/

Privacy contact: keremoztopuzzz@gmail.com

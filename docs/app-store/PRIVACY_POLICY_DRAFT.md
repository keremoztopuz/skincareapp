# Privacy Policy Draft

Effective date: TODO

Skinner is designed to help users review visible skin features, track changes over time, and organize skincare routines.

This draft must be published on a public URL before App Store submission.

## Information We Process

Skinner may process the following information:

- Profile information you enter, such as name, age, gender, and skin type.
- Camera images captured for analysis.
- Analysis results, scan history, scores, and routine selections, stored on your device.
- Subscription status and purchase information handled through Apple and RevenueCat.
- Product and article content fetched from our backend service.

## How Analysis Works

Skin analysis runs in the cloud. There is no analysis model on your device.

1. When you take a photo, your device detects and crops your face locally using Apple's Vision framework. The crop never includes more of the photo than your face.
2. The crop is sent over an encrypted connection to our backend service, which removes image metadata, reduces the image size, and forwards it to Google's Gemini API (Vertex AI) for processing.
3. The service returns numeric readings for six visible features — breakouts, redness, wrinkles, eye bags, pigmentation, and hydration-related signs — which are shown to you and saved on your device.

An internet connection is required to run an analysis. Your history, profile, and routine remain available offline.

Images sent for analysis are processed in real time and are not stored permanently by us. Google retains requests briefly for abuse monitoring and does not use them to train models. Images are never used for advertising and are never sold.

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
- Delete your local data from within the app, or by deleting the app from your device.
- Manage or cancel subscriptions in your Apple Account settings.
- Contact support for privacy questions.

## Contact

Support email: TODO

Support URL: TODO

Privacy contact: TODO

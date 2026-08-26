# Legal site

Source for the public legal pages the app links to from every purchase screen
(App Store Review Guideline 3.1.2). `LegalLinks.swift` points at:

- https://keremoztopuz.github.io/skincare-legal/privacy
- https://keremoztopuz.github.io/skincare-legal/terms

Both are directories with an `index.html`, so the extensionless URLs above
resolve without relying on server-side rewrites.

## Published

Live at https://keremoztopuz.github.io/skincare-legal/ since 26 August 2026,
from the public repo `keremoztopuz/skincare-legal` (Pages: branch `main`,
folder `/`). That repo holds a copy of this folder's contents, not a submodule
— change a page here and push the same change there, or the two drift apart.

## Publishing (first time)

1. Create the public repo `keremoztopuz/skincare-legal`.
2. Copy the **contents** of this folder (not the folder itself) to the repo root
   — `index.html`, `style.css`, `privacy/`, `terms/`.
3. Push to `main`.
4. Settings › Pages › Source: *Deploy from a branch*, branch `main`, folder `/ (root)`.
5. Wait for the first deploy, then confirm both URLs return 200 before submitting
   the app.

`privacy/index.html` is the published form of `docs/app-store/PRIVACY_POLICY_DRAFT.md`.
Change the draft and this page together, or they will drift apart.

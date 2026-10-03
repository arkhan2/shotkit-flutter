# Play Store listing (companion)

Package id: `io.shotkit.shotkit`  
App name: ShotKit  
Category: Tools / Productivity

## Signing

1. Generate an upload keystore (do not commit it):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias shotkit
```

2. Copy `android/key.properties.example` to `android/key.properties` and fill store/key passwords.
3. `flutter build appbundle` signs with that config when `key.properties` exists. Debug signing is used only as a local fallback.

Never commit `android/key.properties`, `*.jks`, or `*.keystore`.

## Store listing copy

Short description (80):

> App Store and Google Play screenshots, made fast.

Full description:

> ShotKit is a guided screenshot studio for App Store and Google Play listings. Sign in with the same account as the ShotKit web studio, upload app captures, attach a Brand Kit, and export store-ready pages at official canvas sizes.
>
> • Same projects, designs, and Brand Kits as the web app
> • Guided composer — no freeform drag editor
> • Export PNG or JPEG, one page or a full set
> • Compliance checks for common store size and format rules
>
> Plans and checkout stay on the web studio. The mobile app enforces the same entitlements.

## Data safety (Play Console)

Collects:

- Email address (account)
- Photos / videos / other files the user uploads (screenshots, logos)
- App activity limited to usage counters for export/resource limits

Not collected for advertising. Not sold. Encrypted in transit. Users can delete project content in-app; account deletion is on the web studio.

Required permissions:

- Camera — capture screens
- Photos / storage — pick screens/logos and save exports
- Internet — auth and sync with Supabase

## Privacy / Terms URLs

Hosted with the GitHub Pages web build:

- https://arkhan2.github.io/shotkit-flutter/legal/privacy.html
- https://arkhan2.github.io/shotkit-flutter/legal/terms.html

## Still required outside this repo

- Google Play Console developer account and listing assets
- Production `SHOTKIT_WEB_URL` once the Next.js studio is deployed
- Google Cloud OAuth client IDs (`GOOGLE_WEB_CLIENT_ID`, Android SHA-1, iOS client)
- Play Billing / Polar if you sell subscriptions on Android (not implemented here)

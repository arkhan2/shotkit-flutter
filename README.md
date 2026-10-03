# ShotKit Mobile

Flutter companion for the ShotKit web studio. Create App Store and Google Play screenshot sets on a phone. Same accounts, projects, Brand Kits, and designs as the web app.

Repo: [arkhan2/shotkit-flutter](https://github.com/arkhan2/shotkit-flutter)  
Web preview (GitHub Pages): https://arkhan2.github.io/shotkit-flutter/

> Not a Canva clone — and not a port of the desktop editor. v1 is a guided composer.

## Stack

- Flutter 3 + Dart 3
- Riverpod + go_router
- Supabase (Auth, Postgres, Storage) — shared with ShotKit web
- Custom `DesignDocument` renderer for preview and export

## Documentation

- [Product spec](docs/product-spec.md)
- [Architecture](docs/architecture.md)
- [Design system](docs/design-system.md)
- [User flows](docs/user-flows.md)
- [Implementation plan](docs/implementation-plan.md)
- [Play Store listing](docs/play-store.md)

## Getting started

```bash
flutter pub get
cp .env.example .env
# set SUPABASE_URL, SUPABASE_ANON_KEY, SHOTKIT_WEB_URL
# optional: GOOGLE_WEB_CLIENT_ID, GOOGLE_IOS_CLIENT_ID, SHOTKIT_LEGAL_URL
flutter run
```

Use the **same** Supabase project as ShotKit web. Never put a service-role key in this app.

### Auth redirects

Register in the Supabase dashboard (alongside the web callback):

- `io.shotkit.app://login-callback`
- GitHub Pages origin if you use web OAuth: `https://arkhan2.github.io/shotkit-flutter`

iOS URL scheme and Android intent filter are declared in the native projects.

### Google Sign-In

Native and Flutter web Google Sign-In both use an ID token (same as the emulator). They need the **Web client ID** from Supabase Auth → Providers → Google (`GOOGLE_WEB_CLIENT_ID`).

1. Create Android and iOS OAuth clients in Google Cloud for `io.shotkit.shotkit`.
2. Add the Android debug and upload SHA-1 fingerprints to the Android client.
3. Put the Web client ID in `assets/config/app.env`. Put the iOS client ID in `GOOGLE_IOS_CLIENT_ID`.
4. On the **Web** client, add Authorized JavaScript origins for Flutter web (exact origin from the address bar), for example:
   - `http://localhost:8080`
   - `http://127.0.0.1:8080`
   - `https://arkhan2.github.io`
5. On that same Web client, Authorized redirect URIs must include:
   - `https://xjoqosirkwvwnpbnubwt.supabase.co/auth/v1/callback`
6. Run Chrome on a stable port so the origin stays the same:

```bash
flutter run -d chrome --web-port=8080 --web-hostname=127.0.0.1
```

### Production web URL

`SHOTKIT_WEB_URL` defaults to `http://127.0.0.1:3000` for local studio work. Set it to the live ShotKit Next.js URL when that site is deployed. Privacy and Terms are served from `SHOTKIT_LEGAL_URL` (GitHub Pages).

## Companion rules

- Persist `DesignDocument` JSON exactly as the web app does
- Resolve canvas sizes from presets — do not hardcode dimensions in UI
- UI must not query Supabase tables directly
- Export at 1:1 canvas pixels through the shared renderer

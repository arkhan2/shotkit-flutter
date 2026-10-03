# ShotKit Mobile

Flutter companion for the ShotKit web studio. Create App Store and Google Play screenshot sets on a phone. Same accounts, projects, Brand Kits, and designs as the web app.

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

## Getting started

```bash
flutter pub get
cp .env.example .env
# set SUPABASE_URL, SUPABASE_ANON_KEY, SHOTKIT_WEB_URL
flutter run
```

Use the **same** Supabase project as ShotKit web. Never put a service-role key in this app.

### Auth redirects

Register in the Supabase dashboard (alongside the web callback):

- `io.shotkit.app://login-callback`

iOS URL scheme and Android intent filter are declared in the native projects.

### Google Sign-In

Set `GOOGLE_WEB_CLIENT_ID` (and iOS client id in `Info.plist` / GoogleService if used). The app exchanges an ID token with Supabase.

## Companion rules

- Persist `DesignDocument` JSON exactly as the web app does
- Resolve canvas sizes from presets — do not hardcode dimensions in UI
- UI must not query Supabase tables directly
- Export at 1:1 canvas pixels through the shared renderer

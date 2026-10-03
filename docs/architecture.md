# ShotKit Mobile — Architecture

## Stack

| Layer | Choice |
| --- | --- |
| App | Flutter 3, Dart 3, iOS + Android |
| State | Riverpod |
| Routing | go_router |
| Backend | Existing ShotKit Supabase (Auth, Postgres, Storage) |
| Auth | `supabase_flutter` + Google Sign-In + deep links |
| Models | Dart 1:1 of web `DesignDocument` / `DesignMetaDocument` |
| Renderer | Document-sized widget / CustomPaint stack |
| Export | `RepaintBoundary.toImage` at canvas pixels + `archive` ZIP |
| Billing v1 | Read entitlements + claim/release export RPCs; checkout on web |

The web repo (`/Users/ar/development/ShotKit`) remains the backend and desktop studio of record. This app never ships a service-role key.

---

## Repository layout

```text
docs/
lib/
  app/                 bootstrap, router, theme, env
  core/                result types, logging, validators
  domain/              DesignDocument, presets, templates, entitlements
  data/                Supabase, repositories, mappers, storage paths
  features/
    auth/
    projects/
    screens/
    brand_kits/
    composer/
    preview/
    export/
    billing/
    account/
  shared/              widgets, renderer, brand
assets/brand/
```

UI never queries Supabase tables directly. Screens call feature notifiers; notifiers call repositories; repositories use the shared client under RLS.

---

## Companion data contract

### Ownership (unchanged from web)

```text
auth.users
  ├── brand_kits
  │     ├── brand_colors
  │     └── assets (optional brand_kit_id; logo via brand_kits.logo_*_asset_id)
  ├── projects
  │     ├── assets (optional project_id)
  │     ├── app_screens → assets
  │     └── designs
  │           └── design_pages
  └── assets (always user-owned)
```

### Persistence split

| Table column | JSON payload |
| --- | --- |
| `designs.document` | `DesignMetaDocument` — set-level metadata |
| `design_pages.document` | `DesignDocument` — one submission image |
| `*.document_version` | Integer schema version (mirrors JSON `version`) |

`DESIGN_DOCUMENT_VERSION = 1`. Breaking shape changes require a bump and a migration path for existing rows.

Relational tables store entities and ownership. Visual composition stays in versioned JSON — not one table per element.

### Storage

Single private bucket: `assets`. Path prefixes (not separate buckets):

| Category | Path |
| --- | --- |
| project screenshots | `users/{userId}/projects/{projectId}/screenshots/{assetId}/{file}` |
| brand logos | `users/{userId}/brand-kits/{brandKitId}/logos/{assetId}/{file}` |
| user fonts | `users/{userId}/fonts/{assetId}/{file}` |

Serve files with signed URLs. Object path must start with `users/{auth.uid()}/`.

---

## Authentication

| Concern | Implementation |
| --- | --- |
| Providers | Email/password + Google |
| Client | `supabase_flutter` |
| Session | Persisted locally; restore on launch |
| Deep link | `io.shotkit.app://login-callback` |
| Gate | Unauthenticated → `/login`; authenticated hitting auth routes → `/app` |

Google OAuth uses the native SDK when configured, then `signInWithIdToken` against Supabase. Redirect URLs must be registered in the Supabase dashboard alongside the web callback.

---

## Domain vs rendering

Portable Dart (must stay interchangeable with web):

- `DesignDocument` / `DesignMetaDocument`
- Canvas presets, mockup catalog IDs, compliance rules
- Template generation and brand application
- Layout apply (geometry + roles; preserve typography/chrome)
- Entitlement checks and export filename helpers

Flutter-only:

- All screens and navigation
- Gesture and bottom-sheet composer UX
- Painting (`DesignPageView`)
- Bitmap export and share/save

**Renderer rule:** one `DesignPageView` used by preview, composer thumbnails, and export. Do not screenshot UI chrome. Pixel-perfect CSS match is not required in v1; layout math (canvas size, mockup screen rect, z-index, transforms) must match so documents stay interchangeable.

Export: hidden artboard sized to `canvas.width × canvas.height`, `pixelRatio: 1.0`, sequential pages to limit memory.

---

## Entitlements

Mobile builds the same snapshot the web server builds:

1. `subscriptions` row
2. `ensure_usage_period` RPC
3. Resource counts
4. `buildEntitlementSnapshot`

Export: `claim_export_usage` before rasterize; `release_export_usage` on failure. One user-initiated export (single page or ZIP) = 1 credit.

Checkout stays on web. Do not invent a second entitlement system. Future IAP (RevenueCat) must reconcile into `billing_events` / `subscriptions`.

---

## Environment

Public only (safe in the client):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SHOTKIT_WEB_URL` (billing / manage-plan deep link)
- Optional `GOOGLE_WEB_CLIENT_ID` / iOS client IDs

Never embed `SUPABASE_SERVICE_ROLE_KEY`.

---

## Deployment notes

- Apply web migrations before using auth-backed features
- Register mobile redirect URLs and Google provider in Supabase
- iOS URL scheme + Android intent filter must match the auth callback
- Entitlements and RLS are the security boundary — treat client checks as UX only

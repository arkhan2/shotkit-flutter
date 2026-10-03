# ShotKit Mobile — agent notes

Companion Flutter app for ShotKit web (`/Users/ar/development/ShotKit`). Read `docs/` before changing product scope.

## Non-negotiables

- This is a **new implementation**, not a conversion of the Next.js editor.
- Share the existing Supabase project. **No service-role key** in the client.
- `DesignDocument` / `DesignMetaDocument` must stay JSON-compatible with the web schema (version 1).
- Canvas sizes come from `CANVAS_PRESETS`. Do not invent dimensions in UI.
- Storage paths must match web: `users/{uid}/projects|brand-kits|fonts/...`
- One renderer (`DesignPageView`) for preview, thumbnails, and export.
- v1 is a **guided composer**. Do not add freeform drag/resize/rotate unless the product spec changes.
- Billing checkout stays on web. Enforce entitlements via the same snapshot + RPCs.
- Product name and colors live in `AppBrand` — do not hardcode "ShotKit" across widgets.

## Layers

```text
lib/app        bootstrap, router, theme, env
lib/core       Result, validators, logging
lib/domain     portable models and catalogs
lib/data       Supabase + repositories
lib/features   screens and notifiers
lib/shared     renderer and reusable widgets
```

Widgets → notifiers → repositories → Supabase. Never skip a layer to "just query".

## When porting from web

Prefer Dart ports of:

- `src/domains/designs/document.ts`
- `src/domains/canvas/presets.ts`
- `src/domains/templates/catalog.ts`
- `src/domains/mockups/catalog.ts`
- `src/domains/export/compliance/*`
- `src/config/storage.ts`

Do not port React editor chrome, `html-to-image`, or Next.js server actions.

## Verification

- A design created here must open in `/app/designs/{id}/edit` on web.
- iPhone 6.9" export must be 1320×2868.
- Failed export must call `release_export_usage`.

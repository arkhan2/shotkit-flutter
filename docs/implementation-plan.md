# ShotKit Mobile — Implementation Plan

Status: Phases 0–6 are implemented in this repository. Fill `assets/config/app.env` with the shared Supabase project before running.

## Phase 0 — Foundation (this repo bootstrap)

**Goal:** Documented product + runnable Flutter shell with brand, routing, and env.

- Product spec, architecture, design system, user flows
- Layered `lib/` folders
- Brand theme (light/dark)
- go_router shells (auth vs app tabs)
- Env: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SHOTKIT_WEB_URL`

**Exit:** App launches to login or a placeholder shell without talking to tables from widgets.

---

## Phase 1 — Auth

**Goal:** Same users as ShotKit web.

- Email/password sign in and sign up
- Google Sign-In (`signInWithIdToken`)
- Session restore, route gate, sign out
- Deep link `io.shotkit.app://login-callback`

**Exit:** Sign in on mobile, see the same user id as on web.

---

## Phase 2 — Workspace

**Goal:** Projects, screens, Brand Kits on the shared schema.

- Project list / create / detail / delete
- Screen upload to `users/{uid}/projects/{id}/screenshots/...`
- Rename, reorder, delete screens
- Brand Kit CRUD (name, logos, colors)
- Attach kit to project

**Exit:** Authenticated user creates a project, uploads screens, manages a kit, data visible on web.

---

## Phase 3 — Domain + renderer

**Goal:** Interchangeable `DesignDocument`.

- Dart models 1:1 with web `document.ts`
- Canvas presets, mockup catalog, compliance rules
- `DesignPageView` for preview (solid/gradient, text, shapes, mockups, logos)

**Exit:** A fixture or web-created page JSON renders at the correct canvas size.

---

## Phase 4 — Guided composer

**Goal:** Size → template → pages → tweaks → autosave.

- Create design from preset + template
- One page per app screen
- Page strip + text / layout / background / brand / mockup sheets
- Debounced autosave of `design_pages.document`

**Exit:** Design created on mobile opens in the web editor with the same pages.

---

## Phase 5 — Export

**Goal:** Store-sized files from the shared renderer.

- Rasterize at preset pixels (`pixelRatio: 1`)
- PNG / JPEG, current / all / ZIP
- Compliance evaluation
- Photos + share sheet
- `claim_export_usage` / `release_export_usage`

**Exit:** Exported iPhone 6.9" PNG is 1320×2868.

---

## Phase 6 — Billing surface + polish

**Goal:** Entitlements UX and empty/error states.

- Entitlement snapshot on Account
- Paywall notices
- Manage on web
- Empty states, store icons, launch polish

**Exit:** Free/Pro copy matches web snapshot; checkout is web-only.

---

## Compatibility rule

Every phase that writes documents must load a web `DesignDocument` fixture and render it without dropping unknown optional fields.

# ShotKit Mobile — Product Specification

## Product overview

**ShotKit Mobile** is the companion app for [ShotKit](https://github.com) web: an opinionated studio for **App Store** and **Google Play** submission screenshots.

It is **not** a Canva clone and **not** a port of the desktop canvas editor. The phone is the fast path to a complete screenshot set. The web studio remains the power editor.

Same accounts, projects, Brand Kits, designs, and pages. A set started on the phone opens in the desktop editor, and vice versa.

Target users are **app developers and designers** who already have screenshots on their device and need a store-ready set in one session.

### Product principles

1. **Companion, not clone** — share the web data contract; do not recreate the desktop chrome.
2. **Opinionated defaults** — templates and layouts over a blank artboard.
3. **Guided, not freeform (v1)** — stepped composer; drag/resize/rotate stays on web.
4. **Speed to a complete set** — project → screens → brand → size → template → pages → export.
5. **Reusable brand identity** — Brand Kits apply consistently across designs.
6. **Store-safe output** — exports match selected canvas presets and compliance rules.

---

## Relationship to ShotKit web

| Concern | Owner |
| --- | --- |
| Auth users, projects, screens, Brand Kits, designs, pages | Shared Supabase |
| `DesignDocument` JSON | Shared contract (version 1) |
| Freeform canvas editor | Web only |
| Guided composer | Mobile v1 (web still has wizard + editor) |
| Billing checkout | Web (Polar). Mobile reads entitlements and links out |
| Export credits | Shared `claim_export_usage` / `release_export_usage` |

---

## Core user workflows (v1)

### 1. Sign in

Email/password or Google. Same Supabase users as the web app.

### 2. Create or open a project

Name (required), description (optional). Existing web projects appear in the list.

### 3. Upload app screenshots

Camera or gallery → project screen library. Rename, reorder, delete.

### 4. Attach a Brand Kit

Select an existing kit, create one (name, light/dark logos, colors), or skip.

### 5. Guided composer

1. Pick store size (canvas preset).
2. Pick a system template.
3. Generate **one page per app screen** (mobile-first; web currently seeds one page).
4. Swipe the set. Per page: edit headline/body, apply a layout recipe, change solid/gradient background, apply brand colors, change mockup style.

### 6. Preview and export

Read-only canvas preview. PNG or JPEG. Current page, all pages, or ZIP. Save to Photos or share sheet. Compliance check before export.

### 7. Manage plan

Account tab shows plan, usage, and **Manage on web**. No in-app purchase in v1.

---

## Features in v1

- Auth: email/password + Google
- Projects: list, create, open, delete
- App screens: camera/gallery, rename, reorder, delete
- Brand Kits: list, create, rename, light/dark logos, colors, attach to project
- Guided composer: size → template → generate → text/layout/background/brand/mockup tweaks
- Shared `DesignDocument` renderer (preview, thumbnails, export)
- Export: PNG/JPEG, ZIP, Photos, share, store compliance
- Entitlements: snapshot + export credit claim; paywall copy; manage plan on web
- Light/dark theme with ShotKit brand tokens

---

## Out of scope (v1)

- Freeform canvas (select, move, resize, rotate, snap, layers)
- Copy/paste page style and import style across designs
- Geometric / abstract background generator
- Custom font upload (curated Google fonts only; web-applied custom fonts warn if unloaded)
- Polar / RevenueCat in-app purchase
- Offline-first editing, collaboration, video / motion previews
- Marketing website inside the app
- iPad / Watch / Desktop mockups beyond the existing catalog

---

## Success criteria

| Outcome | Measure |
| --- | --- |
| Time to first export | New user exports a 5-page set in one session |
| Companion integrity | Design created on mobile opens unchanged in the web editor |
| Platform compliance | Exports match selected canvas presets |
| Quality without design skill | Template + Brand Kit produce store-ready results |

---

## UX direction

Visual character: **modern professional creative SaaS**.

- Clean, premium, minimal
- Strong spacing and typography
- Canvas is the hero; controls are bottom sheets and chips
- One primary action per screen
- Thumb-reach: generate, next, and export sit in the bottom bar
- Feels like a focused creative tool, not an admin dashboard

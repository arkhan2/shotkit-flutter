# ShotKit Mobile — User Flows

## Primary: first export

```text
Launch
  → session? no → Login / Signup
  → session? yes → Projects home
  → Create project (name, optional description)
  → Add app screens (camera / gallery)
  → Attach or create Brand Kit (optional)
  → Guided composer
       → Pick store size
       → Pick template
       → Generate one page per screen
       → Swipe review
       → Edit text / layout / background / brand / mockup
       → Full preview
       → Export PNG or JPEG (page / all / ZIP)
       → Save to Photos or share
```

Companion contract: generate and tweak write `designs` + `design_pages.document` JSON. Opening `/app/designs/{id}/edit` on web must show the same pages.

---

## Auth

- Email sign in / sign up (same Supabase Auth as web)
- Google Sign-In → Supabase `signInWithIdToken`
- Deep link `io.shotkit.app://login-callback` for OAuth return
- Authenticated users hitting login/signup redirect to Projects
- Sign out clears the session and returns to login

---

## Existing web project

```text
Projects home
  → Open project created on web
  → Add screens from camera
  → Create another design (composer)
  → or open an existing design → preview + composer tweaks + export
```

Freeform edits made on web (layers, rotation, custom effects) render read-only. Mobile tweaks only change text content, layout recipe, background, brand colors, and mockup catalog style.

---

## Brand Kits

```text
Brand Kits tab
  → Create kit (name)
  → Upload light / dark logos
  → Add / edit / reorder / delete colors
  → Attach from project setup
```

Deleting a kit unlinks projects (`brand_kit_id` SET NULL). Assets are not cascade-deleted when a logo pointer is cleared.

---

## Export

```text
Preview or composer
  → Export sheet
  → Format PNG | JPEG high | JPEG medium
  → Compliance report
  → If errors: Export anyway (user confirm)
  → claim_export_usage
  → Rasterize sequential pages
  → On failure: release_export_usage
  → Save / share
```

One user-initiated export (single file or ZIP) = 1 monthly credit.

---

## Billing

```text
Account tab
  → Plan name, status, usage (exports, projects, designs, kits)
  → Paywall copy when a Pro feature is locked
  → Manage on web → SHOTKIT_WEB_URL/app/billing
```

No App Store / Play billing in v1.

---

## Edge cases

| Case | Behavior |
| --- | --- |
| No screens | Composer generate disabled; prompt to upload |
| Last page delete | Blocked (same as web) |
| Unloaded custom font | Preview with DM Sans + visible warning |
| Session expired | Return to login; pending local edits flush if possible |
| Upload failure | Delete orphan asset row / storage object |
| Offline | Read cached lists if present; mutations fail with a clear error |
| RLS denial | Surface a generic permission error; never retry with elevated keys |

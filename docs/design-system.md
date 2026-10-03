# ShotKit Mobile — Design System

## Character

Modern professional creative SaaS. Clean, premium, minimal. Strong spacing and typography. Not a colorful admin dashboard. The canvas is the hero.

Tokens come from the web brand module (`APP_BRAND` in ShotKit `src/config/brand.ts`). Do not hardcode the product name — import `AppBrand`.

---

## Color tokens

| Token | Hex | Use |
| --- | --- | --- |
| sky | `#38BDF8` | Primary actions, rings, highlights |
| ink | `#141414` | Body text on light surfaces |
| deep | `#0B1520` | Dark surfaces, marketing ink |
| slate | `#5A7388` | Borders, muted labels |
| mist | `#F4F7FA` | Light canvas background |
| mistDeep | `#E8EEF4` | Secondary light fill |

Light scheme: mist surfaces, ink text, sky primary.
Dark scheme: deep surfaces, mist text, sky primary.

Do not introduce extra accent colors. Brand kit colors appear only inside the canvas and brand editor.

---

## Type

| Role | Size / weight |
| --- | --- |
| Display | 34–40, semibold, tight tracking |
| Title | 22–24, semibold |
| Body | 16, regular, relaxed leading |
| Label | 13, medium, slate |
| Button | 16, semibold |

Primary UI font: **DM Sans** (matches web templates). Headlines on the canvas may use the document `fontFamily`.

---

## Spacing and shape

- Base unit: 4
- Screen padding: 20–24
- Card radius: 16
- Button radius: 12
- Bottom sheet radius: 20
- Icon tap targets: 44

---

## Screen patterns

### App shell

Bottom tabs: **Projects**, **Brand Kits**, **Account**.

### Stepped composer

Full-screen flow, not a properties panel.

1. Size
2. Template
3. Review (canvas hero + page strip)
4. Tweaks as bottom sheets: Text, Layout, Background, Brand, Mockup
5. Export sheet

One primary action in the bottom bar (Continue, Generate, Export).

### Lists

Project and kit cards: name, meta, muted mist fill, 16 radius. Empty states are short and action-led.

### Feedback

- Inline field errors
- Snackbars for save/export failures
- Save status in the composer header (`Saved` / `Saving` / `Unsaved`)

---

## Motion

Short (180–240ms), ease-out. No decorative gradients, no emoji as UI, no drop-shadow stacks on chrome. Canvas mockup shadows are document data, not app chrome.

---

## Accessibility

- Contrast against ink/mist
- Semantic labels on icon-only buttons
- Bottom sheets dismissible
- Dynamic type: body and labels scale; canvas document sizes stay pixel-exact

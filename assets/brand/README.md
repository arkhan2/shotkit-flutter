# Brand and store assets

Canonical marks copied from ShotKit web (`public/brand`):

- `logo-mark.svg` — in-app chrome (also painted as a vector in `BrandMark`)
- `app-icon.svg` — square product icon (stacked frames on deep stage)
- `icon.svg` — same as `app-icon.svg`

iOS, Android, macOS, and web favicons are raster exports of `app-icon.svg`.
Regenerate with:

```bash
NODE_PATH=/Users/ar/development/ShotKit/node_modules node tool/generate_brand_icons.mjs
```

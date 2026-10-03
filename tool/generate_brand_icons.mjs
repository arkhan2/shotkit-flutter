/**
 * Rasterize ShotKit app-icon.svg for iOS, Android, macOS, and web.
 * Uses the same composition as ShotKit web `scripts/generate-brand-icons.ts`.
 *
 *   NODE_PATH=/path/to/shotkit-web/node_modules node tool/generate_brand_icons.mjs
 */
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const { default: sharp } = await import(
  pathToFileURL(path.resolve(ROOT, "../ShotKit/node_modules/sharp/lib/index.js")).href
);
const SVG_PATH = path.join(ROOT, "assets/brand/app-icon.svg");
const DEEP = { r: 0x0b, g: 0x15, b: 0x20, alpha: 1 };

const IOS = [
  ["Icon-App-20x20@1x.png", 20],
  ["Icon-App-20x20@2x.png", 40],
  ["Icon-App-20x20@3x.png", 60],
  ["Icon-App-29x29@1x.png", 29],
  ["Icon-App-29x29@2x.png", 58],
  ["Icon-App-29x29@3x.png", 87],
  ["Icon-App-40x40@1x.png", 40],
  ["Icon-App-40x40@2x.png", 80],
  ["Icon-App-40x40@3x.png", 120],
  ["Icon-App-60x60@2x.png", 120],
  ["Icon-App-60x60@3x.png", 180],
  ["Icon-App-76x76@1x.png", 76],
  ["Icon-App-76x76@2x.png", 152],
  ["Icon-App-83.5x83.5@2x.png", 167],
  ["Icon-App-1024x1024@1x.png", 1024],
];

const ANDROID = [
  ["mipmap-mdpi/ic_launcher.png", 48],
  ["mipmap-hdpi/ic_launcher.png", 72],
  ["mipmap-xhdpi/ic_launcher.png", 96],
  ["mipmap-xxhdpi/ic_launcher.png", 144],
  ["mipmap-xxxhdpi/ic_launcher.png", 192],
];

const MACOS = [
  ["app_icon_16.png", 16],
  ["app_icon_32.png", 32],
  ["app_icon_64.png", 64],
  ["app_icon_128.png", 128],
  ["app_icon_256.png", 256],
  ["app_icon_512.png", 512],
  ["app_icon_1024.png", 1024],
];

async function pngFullBleed(svg, size) {
  return sharp(svg, { density: Math.max(72, size * 4) })
    .resize(size, size, {
      fit: "cover",
      position: "centre",
      background: DEEP,
    })
    .flatten({ background: DEEP })
    .png()
    .toBuffer();
}

async function pngMaskable(svg, size, scale = 0.82) {
  const inner = Math.max(1, Math.round(size * scale));
  const mark = await pngFullBleed(svg, inner);
  return sharp({
    create: {
      width: size,
      height: size,
      channels: 4,
      background: DEEP,
    },
  })
    .composite([{ input: mark, gravity: "center" }])
    .png()
    .toBuffer();
}

async function writePng(file, buffer) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, buffer);
  console.log("wrote", path.relative(ROOT, file));
}

async function main() {
  const svg = await readFile(SVG_PATH);

  const iosDir = path.join(
    ROOT,
    "ios/Runner/Assets.xcassets/AppIcon.appiconset",
  );
  for (const [name, size] of IOS) {
    await writePng(path.join(iosDir, name), await pngFullBleed(svg, size));
  }

  const androidDir = path.join(ROOT, "android/app/src/main/res");
  for (const [name, size] of ANDROID) {
    await writePng(path.join(androidDir, name), await pngFullBleed(svg, size));
  }

  const macDir = path.join(
    ROOT,
    "macos/Runner/Assets.xcassets/AppIcon.appiconset",
  );
  for (const [name, size] of MACOS) {
    await writePng(path.join(macDir, name), await pngFullBleed(svg, size));
  }

  await writePng(
    path.join(ROOT, "web/favicon.png"),
    await pngFullBleed(svg, 32),
  );
  await writePng(
    path.join(ROOT, "web/icons/Icon-192.png"),
    await pngFullBleed(svg, 192),
  );
  await writePng(
    path.join(ROOT, "web/icons/Icon-512.png"),
    await pngFullBleed(svg, 512),
  );
  await writePng(
    path.join(ROOT, "web/icons/Icon-maskable-192.png"),
    await pngMaskable(svg, 192),
  );
  await writePng(
    path.join(ROOT, "web/icons/Icon-maskable-512.png"),
    await pngMaskable(svg, 512),
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

class CanvasPreset {
  const CanvasPreset({
    required this.id,
    required this.label,
    required this.platform,
    required this.deviceType,
    required this.width,
    required this.height,
  });

  final String id;
  final String label;
  final String platform;
  final String deviceType;
  final int width;
  final int height;
}

const canvasPresets = <CanvasPreset>[
  CanvasPreset(
    id: 'iphone_6_9',
    label: 'iPhone 6.9"',
    platform: 'app_store',
    deviceType: 'iphone_6_9',
    width: 1320,
    height: 2868,
  ),
  CanvasPreset(
    id: 'android_phone',
    label: 'Android Phone Portrait',
    platform: 'google_play',
    deviceType: 'android_phone',
    width: 1080,
    height: 1920,
  ),
  CanvasPreset(
    id: 'android_7_tablet',
    label: 'Android 7" Tablet Portrait',
    platform: 'google_play',
    deviceType: 'android_7_tablet',
    width: 1080,
    height: 1920,
  ),
  CanvasPreset(
    id: 'android_7_tablet_landscape',
    label: 'Android 7" Tablet Landscape',
    platform: 'google_play',
    deviceType: 'android_7_tablet_landscape',
    width: 1920,
    height: 1080,
  ),
  CanvasPreset(
    id: 'android_10_tablet',
    label: 'Android 10" Tablet Portrait',
    platform: 'google_play',
    deviceType: 'android_10_tablet',
    width: 1600,
    height: 2560,
  ),
  CanvasPreset(
    id: 'android_10_tablet_landscape',
    label: 'Android 10" Tablet Landscape',
    platform: 'google_play',
    deviceType: 'android_10_tablet_landscape',
    width: 2560,
    height: 1600,
  ),
  CanvasPreset(
    id: 'google_play_feature_graphic',
    label: 'Feature Graphic',
    platform: 'google_play',
    deviceType: 'google_play_feature_graphic',
    width: 1024,
    height: 500,
  ),
];

CanvasPreset? canvasPresetById(String id) {
  for (final preset in canvasPresets) {
    if (preset.id == id) return preset;
  }
  return null;
}

List<CanvasPreset> canvasPresetsFor(String platform) {
  return canvasPresets.where((p) => p.platform == platform).toList();
}

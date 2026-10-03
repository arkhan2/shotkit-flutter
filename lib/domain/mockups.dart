class MockupDefinition {
  const MockupDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.aspectRatio,
    required this.insetTop,
    required this.insetRight,
    required this.insetBottom,
    required this.insetLeft,
    required this.cornerRadius,
    required this.screenCornerRadius,
    required this.cameraType,
    required this.cameraWidth,
    required this.cameraHeight,
    required this.cameraTop,
    required this.defaultFrameColor,
    required this.defaultAppearance,
    required this.tags,
  });

  final String id;
  final String name;
  final String description;
  final double aspectRatio;
  final double insetTop;
  final double insetRight;
  final double insetBottom;
  final double insetLeft;
  final double cornerRadius;
  final double screenCornerRadius;
  final String cameraType;
  final double cameraWidth;
  final double cameraHeight;
  final double cameraTop;
  final String defaultFrameColor;
  final String defaultAppearance;
  final List<String> tags;
}

const mockupCatalog = <MockupDefinition>[
  MockupDefinition(
    id: 'modern-iphone',
    name: 'Modern iPhone',
    description: 'Tall modern phone with Dynamic Island.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.016,
    insetRight: 0.016,
    insetBottom: 0.016,
    insetLeft: 0.016,
    cornerRadius: 0.12,
    screenCornerRadius: 0.11,
    cameraType: 'dynamic-island',
    cameraWidth: 0.28,
    cameraHeight: 0.036,
    cameraTop: 0.016 + 10 / 844,
    defaultFrameColor: '#0B0B0F',
    defaultAppearance: 'dark',
    tags: ['ios', 'modern'],
  ),
  MockupDefinition(
    id: 'minimal-iphone',
    name: 'Minimal iPhone',
    description: 'Slim bezel modern phone.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.013,
    insetRight: 0.013,
    insetBottom: 0.013,
    insetLeft: 0.013,
    cornerRadius: 0.118,
    screenCornerRadius: 0.108,
    cameraType: 'dynamic-island',
    cameraWidth: 0.26,
    cameraHeight: 0.032,
    cameraTop: 0.014 + 10 / 844,
    defaultFrameColor: '#111827',
    defaultAppearance: 'dark',
    tags: ['ios', 'minimal'],
  ),
  MockupDefinition(
    id: 'android-phone',
    name: 'Android Phone',
    description: 'Android-style phone with punch-hole camera.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.018,
    insetRight: 0.018,
    insetBottom: 0.018,
    insetLeft: 0.018,
    cornerRadius: 0.12,
    screenCornerRadius: 0.1,
    cameraType: 'punch-hole',
    cameraWidth: 0.045,
    cameraHeight: 0.02,
    cameraTop: 0.016 + 10 / 820,
    defaultFrameColor: '#111827',
    defaultAppearance: 'dark',
    tags: ['android', 'phone'],
  ),
  MockupDefinition(
    id: 'android-7-tablet',
    name: 'Android 7" Tablet',
    description: 'Compact Android tablet frame.',
    aspectRatio: 9 / 16,
    insetTop: 0.028,
    insetRight: 0.028,
    insetBottom: 0.028,
    insetLeft: 0.028,
    cornerRadius: 0.045,
    screenCornerRadius: 0.035,
    cameraType: 'punch-hole',
    cameraWidth: 0.028,
    cameraHeight: 0.016,
    cameraTop: 0.02,
    defaultFrameColor: '#111827',
    defaultAppearance: 'dark',
    tags: ['android', 'tablet'],
  ),
  MockupDefinition(
    id: 'android-10-tablet',
    name: 'Android 10" Tablet',
    description: 'Larger Android tablet frame.',
    aspectRatio: 9 / 16,
    insetTop: 0.024,
    insetRight: 0.024,
    insetBottom: 0.024,
    insetLeft: 0.024,
    cornerRadius: 0.04,
    screenCornerRadius: 0.03,
    cameraType: 'punch-hole',
    cameraWidth: 0.022,
    cameraHeight: 0.012,
    cameraTop: 0.018,
    defaultFrameColor: '#0F172A',
    defaultAppearance: 'dark',
    tags: ['android', 'tablet'],
  ),
  MockupDefinition(
    id: 'android-7-tablet-landscape',
    name: 'Android 7" Tablet Landscape',
    description: 'Landscape 7-inch tablet.',
    aspectRatio: 16 / 9,
    insetTop: 0.04,
    insetRight: 0.028,
    insetBottom: 0.04,
    insetLeft: 0.028,
    cornerRadius: 0.055,
    screenCornerRadius: 0.04,
    cameraType: 'punch-hole',
    cameraWidth: 0.016,
    cameraHeight: 0.028,
    cameraTop: 0.03,
    defaultFrameColor: '#111827',
    defaultAppearance: 'dark',
    tags: ['android', 'tablet', 'landscape'],
  ),
  MockupDefinition(
    id: 'android-10-tablet-landscape',
    name: 'Android 10" Tablet Landscape',
    description: 'Landscape 10-inch tablet.',
    aspectRatio: 16 / 9,
    insetTop: 0.035,
    insetRight: 0.024,
    insetBottom: 0.035,
    insetLeft: 0.024,
    cornerRadius: 0.05,
    screenCornerRadius: 0.035,
    cameraType: 'punch-hole',
    cameraWidth: 0.012,
    cameraHeight: 0.022,
    cameraTop: 0.028,
    defaultFrameColor: '#0F172A',
    defaultAppearance: 'dark',
    tags: ['android', 'tablet', 'landscape'],
  ),
  MockupDefinition(
    id: 'borderless-phone',
    name: 'Borderless Phone',
    description: 'Nearly edge-to-edge screen.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.016,
    insetRight: 0.016,
    insetBottom: 0.016,
    insetLeft: 0.016,
    cornerRadius: 0.12,
    screenCornerRadius: 0.11,
    cameraType: 'none',
    cameraWidth: 0,
    cameraHeight: 0,
    cameraTop: 0,
    defaultFrameColor: '#020617',
    defaultAppearance: 'dark',
    tags: ['borderless'],
  ),
  MockupDefinition(
    id: 'dark-phone',
    name: 'Dark Phone',
    description: 'Matte black frame.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.016,
    insetRight: 0.016,
    insetBottom: 0.016,
    insetLeft: 0.016,
    cornerRadius: 0.12,
    screenCornerRadius: 0.11,
    cameraType: 'notch',
    cameraWidth: 0.42,
    cameraHeight: 0.03,
    cameraTop: 0.012,
    defaultFrameColor: '#000000',
    defaultAppearance: 'dark',
    tags: ['dark'],
  ),
  MockupDefinition(
    id: 'light-phone',
    name: 'Light Phone',
    description: 'Silver / light frame.',
    aspectRatio: 9 / 19.5,
    insetTop: 0.016,
    insetRight: 0.016,
    insetBottom: 0.016,
    insetLeft: 0.016,
    cornerRadius: 0.12,
    screenCornerRadius: 0.11,
    cameraType: 'dynamic-island',
    cameraWidth: 0.28,
    cameraHeight: 0.036,
    cameraTop: 0.016,
    defaultFrameColor: '#E5E7EB',
    defaultAppearance: 'light',
    tags: ['light'],
  ),
];

const _legacyMockupIds = {
  'iphone-15-pro': 'modern-iphone',
  'iphone-16': 'modern-iphone',
  'iphone-16-plus': 'modern-iphone',
  'pixel-8': 'android-phone',
};

String resolveMockupId(String id) => _legacyMockupIds[id] ?? id;

MockupDefinition? mockupById(String id) {
  final resolved = resolveMockupId(id);
  for (final item in mockupCatalog) {
    if (item.id == resolved) return item;
  }
  return null;
}

String defaultMockupDeviceId({
  required String platform,
  required String deviceType,
}) {
  switch (deviceType) {
    case 'android_7_tablet':
      return 'android-7-tablet';
    case 'android_7_tablet_landscape':
      return 'android-7-tablet-landscape';
    case 'android_10_tablet':
      return 'android-10-tablet';
    case 'android_10_tablet_landscape':
      return 'android-10-tablet-landscape';
    case 'android_phone':
    case 'google_play_feature_graphic':
      return 'android-phone';
    case 'iphone_6_9':
      return 'modern-iphone';
    default:
      return platform == 'google_play' ? 'android-phone' : 'modern-iphone';
  }
}

const freeMockupIds = {
  'modern-iphone',
  'android-phone',
  'android-7-tablet',
  'android-7-tablet-landscape',
  'android-10-tablet',
  'android-10-tablet-landscape',
};

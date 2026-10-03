import 'package:uuid/uuid.dart';

import 'document.dart';
import 'mockups.dart';

const templateScreenPlaceholder = '__SCREEN__';
const templateScreen2Placeholder = '__SCREEN_2__';
const templateLogoPlaceholder = '__LOGO__';

const mockupZ = 310;
const textZ = 910;
const logoZ = 710;

class SystemTemplate {
  const SystemTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.build,
  });

  final String id;
  final String name;
  final String description;
  final DesignDocument Function(CanvasConfig canvas) build;
}

final _uuid = Uuid();

String _id(String prefix) => '${prefix}_${_uuid.v4()}';

int _deviceAspectHeight(int width, String deviceId) {
  final aspect = mockupById(deviceId)?.aspectRatio ?? 9 / 19.5;
  return (width / aspect).round();
}

MockupElement _mockup({
  required CanvasConfig canvas,
  required double x,
  required double y,
  required int width,
  int? height,
  double rotation = 0,
  String? style,
  String? deviceId,
  String? screenAssetId,
  int? zIndex,
  double cropOffsetX = 0.5,
  String? name,
  String role = 'primary-mockup',
}) {
  final id = deviceId ??
      defaultMockupDeviceId(
        platform: canvas.platform,
        deviceType: canvas.deviceType,
      );
  final def = mockupById(id);
  final h = height ?? _deviceAspectHeight(width, id);
  return MockupElement(
    id: _id('mockup'),
    name: name ?? (def?.tags.contains('tablet') == true ? 'Tablet' : 'Phone'),
    transform: ElementTransform(
      x: x,
      y: y,
      width: width.toDouble(),
      height: h.toDouble(),
      rotation: rotation,
    ),
    zIndex: zIndex ?? mockupZ,
    locked: false,
    visible: true,
    role: role,
    screenAssetId: screenAssetId ?? templateScreenPlaceholder,
    style: style ?? 'full',
    deviceId: id,
    frameColor: def?.defaultFrameColor ?? '#0B0B0F',
    appearance: def?.defaultAppearance ?? 'dark',
    cropOffsetX: cropOffsetX,
    shadow: const {
      'enabled': true,
      'color': '#000000',
      'blur': 48,
      'offsetX': 0,
      'offsetY': 28,
      'opacity': 0.35,
    },
  );
}

TextElement _headline({
  required CanvasConfig canvas,
  required String content,
  required double x,
  required double y,
  required double width,
  required double height,
  String color = '#FFFFFF',
  String align = 'center',
  double? fontSize,
  String role = 'heading',
}) {
  return TextElement(
    id: _id('headline'),
    name: 'Headline',
    transform: ElementTransform(x: x, y: y, width: width, height: height),
    zIndex: textZ,
    locked: false,
    visible: true,
    role: role,
    content: content,
    fontFamily: 'DM Sans',
    fontSize: fontSize ?? (canvas.width * 0.065).roundToDouble(),
    fontWeight: 600,
    fontStyle: 'normal',
    lineHeight: 1.12,
    letterSpacing: 0,
    color: color,
    align: align,
    effects: const TextEffects(
      shadow: {
        'enabled': true,
        'color': '#00000066',
        'blur': 20,
        'offsetX': 0,
        'offsetY': 8,
      },
    ),
  );
}

LogoElement _logo({
  required CanvasConfig canvas,
  required double x,
  required double y,
  required double width,
  required double height,
}) {
  return LogoElement(
    id: _id('logo'),
    name: 'Logo',
    transform: ElementTransform(x: x, y: y, width: width, height: height),
    zIndex: logoZ,
    locked: false,
    visible: true,
    role: 'logo',
    assetId: templateLogoPlaceholder,
    fit: 'contain',
  );
}

bool _isFeature(CanvasConfig canvas) =>
    canvas.deviceType == 'google_play_feature_graphic';

DesignDocument _featureBanner(CanvasConfig canvas) {
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final deviceId = defaultMockupDeviceId(
    platform: canvas.platform,
    deviceType: canvas.deviceType,
  );
  final mockupH = (h * 1.35).round();
  final aspect = mockupById(deviceId)?.aspectRatio ?? 9 / 19.5;
  final mockupW = (mockupH * aspect).round();
  return DesignDocument(
    canvas: canvas,
    background: const GradientBackground(
      angle: 120,
      stops: [
        GradientStop(color: '#0F172A', position: 0),
        GradientStop(color: '#1D4ED8', position: 1),
      ],
    ),
    elements: [
      _logo(canvas: canvas, x: w * 0.06, y: h * 0.12, width: w * 0.12, height: h * 0.14),
      _headline(
        canvas: canvas,
        content: 'Feature your app',
        x: w * 0.06,
        y: h * 0.32,
        width: w * 0.48,
        height: h * 0.4,
        align: 'left',
        fontSize: h * 0.12,
      ),
      _mockup(
        canvas: canvas,
        x: w * 0.55,
        y: h * 0.08,
        width: mockupW,
        height: mockupH,
        style: 'cropped',
        deviceId: deviceId,
      ),
    ],
  );
}

DesignDocument buildCenteredPhone(CanvasConfig canvas) {
  if (_isFeature(canvas)) return _featureBanner(canvas);
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final mockupW = (w * 0.62).round();
  return DesignDocument(
    canvas: canvas,
    background: const GradientBackground(
      angle: 165,
      stops: [
        GradientStop(color: '#0F172A', position: 0),
        GradientStop(color: '#1D4ED8', position: 1),
      ],
    ),
    elements: [
      _logo(
        canvas: canvas,
        x: w * 0.5 - w * 0.08,
        y: h * 0.05,
        width: w * 0.16,
        height: h * 0.045,
      ),
      _headline(
        canvas: canvas,
        content: 'Make every moment count',
        x: w * 0.08,
        y: h * 0.12,
        width: w * 0.84,
        height: h * 0.14,
        fontSize: w * 0.07,
      ),
      _mockup(
        canvas: canvas,
        x: (w - mockupW) / 2,
        y: h * 0.32,
        width: mockupW,
      ),
    ],
  );
}

DesignDocument buildCroppedPhone(CanvasConfig canvas) {
  if (_isFeature(canvas)) return _featureBanner(canvas);
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final mockupW = (w * 0.78).round();
  return DesignDocument(
    canvas: canvas,
    background: const GradientBackground(
      angle: 140,
      stops: [
        GradientStop(color: '#111827', position: 0),
        GradientStop(color: '#2563EB', position: 1),
      ],
    ),
    elements: [
      _headline(
        canvas: canvas,
        content: 'Your best feature, front and center',
        x: w * 0.08,
        y: h * 0.08,
        width: w * 0.84,
        height: h * 0.14,
        fontSize: w * 0.06,
      ),
      _mockup(
        canvas: canvas,
        x: (w - mockupW) / 2,
        y: h * 0.28,
        width: mockupW,
        style: 'cropped',
      ),
      _logo(canvas: canvas, x: w * 0.08, y: h * 0.9, width: w * 0.16, height: h * 0.04),
    ],
  );
}

DesignDocument buildTwoPhones(CanvasConfig canvas) {
  if (_isFeature(canvas)) return _featureBanner(canvas);
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final mockupW = (w * 0.4).round();
  final gap = w * 0.04;
  final startX = (w - (mockupW * 2 + gap)) / 2;
  return DesignDocument(
    canvas: canvas,
    background: const SolidBackground(color: '#0B1220'),
    elements: [
      _headline(
        canvas: canvas,
        content: 'Two screens. One story.',
        x: w * 0.08,
        y: h * 0.1,
        width: w * 0.84,
        height: h * 0.12,
        fontSize: w * 0.055,
      ),
      _mockup(
        name: 'Phone 1',
        canvas: canvas,
        x: startX,
        y: h * 0.3,
        width: mockupW,
        deviceId: 'minimal-iphone',
      ),
      _mockup(
        name: 'Phone 2',
        canvas: canvas,
        x: startX + mockupW + gap,
        y: h * 0.3,
        width: mockupW,
        deviceId: 'minimal-iphone',
        screenAssetId: templateScreen2Placeholder,
        zIndex: mockupZ + 10,
        cropOffsetX: 0.65,
        role: 'secondary-mockup',
      ),
    ],
  );
}

DesignDocument buildOverlappingPhones(CanvasConfig canvas) {
  if (_isFeature(canvas)) return _featureBanner(canvas);
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final mockupW = (w * 0.48).round();
  return DesignDocument(
    canvas: canvas,
    background: const GradientBackground(
      angle: 160,
      stops: [
        GradientStop(color: '#0F172A', position: 0),
        GradientStop(color: '#334155', position: 1),
      ],
    ),
    elements: [
      _headline(
        canvas: canvas,
        content: 'Layered. Polished. Ready.',
        x: w * 0.08,
        y: h * 0.08,
        width: w * 0.84,
        height: h * 0.12,
        fontSize: w * 0.055,
      ),
      _mockup(
        name: 'Phone back',
        canvas: canvas,
        x: w * 0.08,
        y: h * 0.28,
        width: mockupW,
        rotation: -8,
        deviceId: 'light-phone',
      ),
      _mockup(
        name: 'Phone front',
        canvas: canvas,
        x: w * 0.42,
        y: h * 0.34,
        width: mockupW,
        rotation: 6,
        screenAssetId: templateScreen2Placeholder,
        zIndex: mockupZ + 20,
        deviceId: 'modern-iphone',
      ),
    ],
  );
}

DesignDocument buildPhoneAndText(CanvasConfig canvas) {
  if (_isFeature(canvas)) return _featureBanner(canvas);
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final deviceId = canvas.deviceType.contains('tablet')
      ? defaultMockupDeviceId(
          platform: canvas.platform,
          deviceType: canvas.deviceType,
        )
      : 'light-phone';
  final mockupW = (w * 0.7).round();
  return DesignDocument(
    canvas: canvas,
    background: const SolidBackground(color: '#F8FAFC'),
    elements: [
      _mockup(
        canvas: canvas,
        x: (w - mockupW) / 2,
        y: h * 0.08,
        width: mockupW,
        deviceId: deviceId,
      ),
      _headline(
        canvas: canvas,
        content: 'Built for everyday focus',
        x: w * 0.1,
        y: h * 0.72,
        width: w * 0.8,
        height: h * 0.1,
        color: '#0F172A',
        fontSize: w * 0.052,
      ),
      TextElement(
        id: _id('body'),
        name: 'Body',
        transform: ElementTransform(
          x: w * 0.12,
          y: h * 0.84,
          width: w * 0.76,
          height: h * 0.08,
        ),
        zIndex: textZ - 5,
        locked: false,
        visible: true,
        role: 'body',
        content: 'Clear screens. Clear message.',
        fontFamily: 'DM Sans',
        fontSize: w * 0.032,
        fontWeight: 500,
        fontStyle: 'normal',
        lineHeight: 1.3,
        letterSpacing: 0,
        color: '#475569',
        align: 'center',
        effects: const TextEffects(),
      ),
      _logo(
        canvas: canvas,
        x: w * 0.5 - w * 0.07,
        y: h * 0.93,
        width: w * 0.14,
        height: h * 0.035,
      ),
    ],
  );
}

final systemTemplates = <SystemTemplate>[
  SystemTemplate(
    id: 'system_bold_headline',
    name: 'Centered Phone',
    description: 'Headline above a centered full phone mockup.',
    build: buildCenteredPhone,
  ),
  SystemTemplate(
    id: 'system_clean_focus',
    name: 'Phone + Text',
    description: 'Light canvas with a large phone and caption block.',
    build: buildPhoneAndText,
  ),
  SystemTemplate(
    id: 'system_feature_spotlight',
    name: 'Cropped Phone',
    description: 'Large phone extending beyond the canvas edge.',
    build: buildCroppedPhone,
  ),
  SystemTemplate(
    id: 'system_two_phones',
    name: 'Two Phones',
    description: 'Side-by-side phones using two app screens.',
    build: buildTwoPhones,
  ),
  SystemTemplate(
    id: 'system_overlapping_phones',
    name: 'Overlapping Phones',
    description: 'Layered phones with rotation for depth.',
    build: buildOverlappingPhones,
  ),
  SystemTemplate(
    id: 'system_centered_phone',
    name: 'Centered Phone (alt)',
    description: 'Alternate centered phone composition.',
    build: buildCenteredPhone,
  ),
];

SystemTemplate? systemTemplateById(String id) {
  for (final template in systemTemplates) {
    if (template.id == id) return template;
  }
  return null;
}

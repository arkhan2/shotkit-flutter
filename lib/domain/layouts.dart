import 'document.dart';
import 'generate.dart';
import 'mockups.dart';
import 'templates.dart';

class LayoutRecipe {
  const LayoutRecipe({
    required this.id,
    required this.name,
    required this.category,
    required this.build,
  });

  final String id;
  final String name;
  final String category;
  final DesignDocument Function(CanvasConfig canvas) build;
}

final layoutRecipes = <LayoutRecipe>[
  LayoutRecipe(
    id: 'hero',
    name: 'Hero',
    category: 'hero',
    build: buildCenteredPhone,
  ),
  LayoutRecipe(
    id: 'feature',
    name: 'Feature',
    category: 'feature',
    build: buildCroppedPhone,
  ),
  LayoutRecipe(
    id: 'minimal',
    name: 'Minimal',
    category: 'minimal',
    build: buildPhoneAndText,
  ),
  LayoutRecipe(
    id: 'two-phones',
    name: 'Two Phones',
    category: 'showcase',
    build: buildTwoPhones,
  ),
  LayoutRecipe(
    id: 'overlap',
    name: 'Overlap',
    category: 'showcase',
    build: buildOverlappingPhones,
  ),
  LayoutRecipe(
    id: 'split',
    name: 'Split',
    category: 'split',
    build: _buildSplit,
  ),
  LayoutRecipe(
    id: 'peek',
    name: 'Peek',
    category: 'peek',
    build: _buildPeek,
  ),
];

DesignDocument _buildSplit(CanvasConfig canvas) {
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final deviceId = defaultMockupDeviceId(
    platform: canvas.platform,
    deviceType: canvas.deviceType,
  );
  final mockupW = (w * 0.48).round();
  return DesignDocument(
    canvas: canvas,
    background: const GradientBackground(
      angle: 180,
      stops: [
        GradientStop(color: '#0F172A', position: 0),
        GradientStop(color: '#1E3A8A', position: 1),
      ],
    ),
    elements: [
      TextElement(
        id: 'split_heading',
        name: 'Headline',
        transform: ElementTransform(
          x: w * 0.08,
          y: h * 0.28,
          width: w * 0.4,
          height: h * 0.28,
        ),
        zIndex: textZ,
        locked: false,
        visible: true,
        role: 'heading',
        content: 'Designed to convert',
        fontFamily: 'DM Sans',
        fontSize: w * 0.07,
        fontWeight: 600,
        fontStyle: 'normal',
        lineHeight: 1.1,
        letterSpacing: 0,
        color: '#FFFFFF',
        align: 'left',
        effects: const TextEffects(),
      ),
      MockupElement(
        id: 'split_phone',
        name: 'Phone',
        transform: ElementTransform(
          x: w * 0.5,
          y: h * 0.18,
          width: mockupW.toDouble(),
          height: (mockupW / (mockupById(deviceId)?.aspectRatio ?? 9 / 19.5)),
        ),
        zIndex: mockupZ,
        locked: false,
        visible: true,
        role: 'primary-mockup',
        screenAssetId: templateScreenPlaceholder,
        style: 'full',
        deviceId: deviceId,
        frameColor: mockupById(deviceId)?.defaultFrameColor ?? '#0B0B0F',
      ),
    ],
  );
}

DesignDocument _buildPeek(CanvasConfig canvas) {
  final w = canvas.width.toDouble();
  final h = canvas.height.toDouble();
  final deviceId = defaultMockupDeviceId(
    platform: canvas.platform,
    deviceType: canvas.deviceType,
  );
  final mockupW = (w * 0.86).round();
  return DesignDocument(
    canvas: canvas,
    background: const SolidBackground(color: '#111827'),
    elements: [
      TextElement(
        id: 'peek_heading',
        name: 'Headline',
        transform: ElementTransform(
          x: w * 0.08,
          y: h * 0.08,
          width: w * 0.84,
          height: h * 0.16,
        ),
        zIndex: textZ,
        locked: false,
        visible: true,
        role: 'heading',
        content: 'See it in action',
        fontFamily: 'DM Sans',
        fontSize: w * 0.068,
        fontWeight: 600,
        fontStyle: 'normal',
        lineHeight: 1.1,
        letterSpacing: 0,
        color: '#FFFFFF',
        align: 'center',
        effects: const TextEffects(),
      ),
      MockupElement(
        id: 'peek_phone',
        name: 'Phone',
        transform: ElementTransform(
          x: (w - mockupW) / 2,
          y: h * 0.28,
          width: mockupW.toDouble(),
          height: mockupW / (mockupById(deviceId)?.aspectRatio ?? 9 / 19.5),
        ),
        zIndex: mockupZ,
        locked: false,
        visible: true,
        role: 'primary-mockup',
        screenAssetId: templateScreenPlaceholder,
        style: 'cropped',
        deviceId: deviceId,
        frameColor: mockupById(deviceId)?.defaultFrameColor ?? '#0B0B0F',
      ),
    ],
  );
}

/// Repositions composition using a layout recipe while preserving copy and chrome.
DesignDocument applyLayoutRecipe({
  required DesignDocument source,
  required String recipeId,
  required String primaryScreenAssetId,
  String? secondaryScreenAssetId,
  String? logoAssetId,
}) {
  final recipe = layoutRecipes.cast<LayoutRecipe?>().firstWhere(
        (r) => r!.id == recipeId,
        orElse: () => null,
      );
  if (recipe == null) return source;

  final heading = source.elements.whereType<TextElement>().cast<TextElement?>().firstWhere(
        (t) => t!.role == 'heading' || t.name == 'Headline',
        orElse: () => source.elements.whereType<TextElement>().firstOrNull,
      );
  final body = source.elements.whereType<TextElement>().cast<TextElement?>().firstWhere(
        (t) => t!.role == 'body' || t.name == 'Body',
        orElse: () => null,
      );
  final mockup = source.elements.whereType<MockupElement>().firstOrNull;

  var generated = recipe.build(source.canvas);
  generated = generatePageFromTemplate(
    template: SystemTemplate(
      id: recipe.id,
      name: recipe.name,
      description: recipe.name,
      build: (_) => generated,
    ),
    canvas: source.canvas,
    screenAssetId: primaryScreenAssetId,
    secondaryScreenAssetId: secondaryScreenAssetId,
    brandKit: null,
  );

  generated = generated.copyWith(background: source.background);
  if (heading != null) {
    generated = applyTextEdits(generated, heading: heading.content, body: body?.content);
  }
  if (mockup != null) {
    generated = generated.copyWith(
      elements: generated.elements.map((el) {
        if (el is MockupElement) {
          return el.copyWith(
            deviceId: mockup.deviceId,
            style: mockup.style,
            frameColor: mockup.frameColor,
            appearance: mockup.appearance,
          );
        }
        return el;
      }).toList(),
    );
  }
  return generated;
}

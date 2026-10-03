import 'document.dart';
import 'models.dart';
import 'templates.dart';

String _findColor(BrandKitWithColors? kit, List<String> names, String fallback) {
  if (kit == null || kit.colors.isEmpty) return fallback;
  final lower = names.map((n) => n.toLowerCase()).toList();
  for (final color in kit.colors) {
    if (lower.contains(color.name.trim().toLowerCase())) return color.hex;
  }
  return kit.colors.first.hex;
}

BackgroundConfig applyBrandBackground(
  BackgroundConfig background,
  BrandKitWithColors? kit,
) {
  if (kit == null || kit.colors.isEmpty) return background;
  final primary = _findColor(kit, ['primary', 'accent'], '#1D4ED8');
  final secondary = _findColor(kit, ['secondary', 'background'], '#0F172A');
  if (background is SolidBackground) {
    return SolidBackground(color: primary);
  }
  if (background is GradientBackground) {
    return GradientBackground(
      angle: background.angle,
      stops: [
        GradientStop(color: secondary, position: 0),
        GradientStop(color: primary, position: 1),
      ],
    );
  }
  return background;
}

DesignElement? applyBrandToElement({
  required DesignElement element,
  required BrandKitWithColors? brandKit,
  required String screenAssetId,
  String? secondaryScreenAssetId,
  String? logoAssetId,
}) {
  if (element is MockupElement) {
    final nextId = element.screenAssetId == templateScreen2Placeholder
        ? (secondaryScreenAssetId ?? screenAssetId)
        : screenAssetId;
    return element.copyWith(screenAssetId: nextId);
  }
  if (element is LogoElement) {
    if (logoAssetId == null) return null;
    return LogoElement(
      id: element.id,
      name: element.name,
      transform: element.transform,
      zIndex: element.zIndex,
      locked: element.locked,
      visible: element.visible,
      role: element.role,
      assetId: logoAssetId,
      fit: element.fit,
    );
  }
  if (element is TextElement) {
    final textColor = _findColor(brandKit, ['text', 'foreground'], element.color);
    final upper = element.color.toUpperCase();
    final nextColor = (upper == '#FFFFFF' || upper == '#F8FAFC')
        ? element.color
        : textColor;
    return element.copyWith(color: nextColor);
  }
  if (element is ShapeElement && brandKit != null) {
    final accent = _findColor(brandKit, ['accent', 'primary'], element.fill);
    return ShapeElement(
      id: element.id,
      name: element.name,
      transform: element.transform,
      zIndex: element.zIndex,
      locked: element.locked,
      visible: element.visible,
      role: element.role,
      shape: element.shape,
      fill: accent,
      stroke: element.stroke,
      strokeWidth: element.strokeWidth,
      points: element.points,
      cornerRadius: element.cornerRadius,
    );
  }
  return element;
}

DesignDocument generatePageFromTemplate({
  required SystemTemplate template,
  required CanvasConfig canvas,
  required String screenAssetId,
  String? secondaryScreenAssetId,
  BrandKitWithColors? brandKit,
}) {
  final base = template.build(canvas);
  final logoAssetId = brandKit?.resolvedLogoAssetId;
  final elements = base.elements
      .map(
        (el) => applyBrandToElement(
          element: el,
          brandKit: brandKit,
          screenAssetId: screenAssetId,
          secondaryScreenAssetId: secondaryScreenAssetId,
          logoAssetId: logoAssetId,
        ),
      )
      .whereType<DesignElement>()
      .toList();
  return DesignDocument(
    canvas: canvas,
    background: applyBrandBackground(base.background, brandKit),
    elements: elements,
  );
}

DesignDocument applyTextEdits(DesignDocument document, {String? heading, String? body}) {
  return document.copyWith(
    elements: document.elements.map((el) {
      if (el is! TextElement) return el;
      if (heading != null && (el.role == 'heading' || el.name == 'Headline')) {
        return el.copyWith(content: heading);
      }
      if (body != null && (el.role == 'body' || el.name == 'Body')) {
        return el.copyWith(content: body);
      }
      return el;
    }).toList(),
  );
}

DesignDocument applySolidOrGradientBackground(
  DesignDocument document,
  BackgroundConfig background,
) {
  return document.copyWith(background: background);
}

DesignDocument applyBrandColorsToDocument(
  DesignDocument document,
  BrandKitWithColors kit,
) {
  return document.copyWith(
    background: applyBrandBackground(document.background, kit),
    elements: document.elements
        .map((el) {
          if (el is TextElement) {
            final upper = el.color.toUpperCase();
            if (upper == '#FFFFFF' || upper == '#F8FAFC') return el;
            return el.copyWith(
              color: _findColor(kit, ['text', 'foreground'], el.color),
            );
          }
          if (el is ShapeElement) {
            return ShapeElement(
              id: el.id,
              name: el.name,
              transform: el.transform,
              zIndex: el.zIndex,
              locked: el.locked,
              visible: el.visible,
              role: el.role,
              shape: el.shape,
              fill: _findColor(kit, ['accent', 'primary'], el.fill),
              stroke: el.stroke,
              strokeWidth: el.strokeWidth,
              points: el.points,
              cornerRadius: el.cornerRadius,
            );
          }
          return el;
        })
        .toList(),
  );
}

DesignDocument applyMockupStyle(
  DesignDocument document, {
  required String deviceId,
  required String style,
}) {
  return document.copyWith(
    elements: document.elements.map((el) {
      if (el is! MockupElement) return el;
      final def = /* keep frame from catalog */ deviceId;
      return el.copyWith(deviceId: def, style: style);
    }).toList(),
  );
}

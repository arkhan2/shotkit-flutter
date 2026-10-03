const designDocumentVersion = 1;

class Size2D {
  const Size2D(this.width, this.height);
  final double width;
  final double height;
}

class Point2D {
  const Point2D(this.x, this.y);
  final double x;
  final double y;
}

class ElementTransform {
  const ElementTransform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
    this.opacity = 1,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double opacity;

  ElementTransform copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? opacity,
  }) {
    return ElementTransform(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'opacity': opacity,
      };

  factory ElementTransform.fromJson(Map<String, dynamic> json) {
    return ElementTransform(
      x: _d(json['x']),
      y: _d(json['y']),
      width: _d(json['width']),
      height: _d(json['height']),
      rotation: _d(json['rotation']),
      opacity: _d(json['opacity'], 1),
    );
  }
}

class CanvasConfig {
  const CanvasConfig({
    required this.presetId,
    required this.platform,
    required this.deviceType,
    required this.width,
    required this.height,
  });

  final String presetId;
  final String platform;
  final String deviceType;
  final int width;
  final int height;

  Map<String, dynamic> toJson() => {
        'presetId': presetId,
        'platform': platform,
        'deviceType': deviceType,
        'width': width,
        'height': height,
      };

  factory CanvasConfig.fromJson(Map<String, dynamic> json) {
    return CanvasConfig(
      presetId: json['presetId'] as String? ?? '',
      platform: json['platform'] as String? ?? 'app_store',
      deviceType: json['deviceType'] as String? ?? 'iphone_6_9',
      width: _i(json['width']),
      height: _i(json['height']),
    );
  }
}

sealed class BackgroundConfig {
  const BackgroundConfig();
  String get type;
  Map<String, dynamic> toJson();

  factory BackgroundConfig.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'gradient':
        return GradientBackground(
          angle: _d(json['angle']),
          stops: _stops(json['stops']),
        );
      case 'geometric':
        return GeometricBackground(
          seed: _i(json['seed']),
          palette: _stringList(json['palette']),
          density: _d(json['density']),
          complexity: _d(json['complexity']),
          style: json['style'] as String? ?? 'abstract',
          presetId: json['presetId'] as String?,
          shapeCount: json['shapeCount'] == null ? null : _i(json['shapeCount']),
          useBrandColors: json['useBrandColors'] as bool?,
          baseColor: json['baseColor'] as String?,
        );
      case 'image':
        return ImageBackground(
          assetId: json['assetId'] as String? ?? '',
          fit: json['fit'] as String? ?? 'cover',
          blur: _d(json['blur']),
          opacity: _d(json['opacity'], 1),
        );
      default:
        return SolidBackground(color: json['color'] as String? ?? '#0F172A');
    }
  }
}

class SolidBackground extends BackgroundConfig {
  const SolidBackground({required this.color});
  final String color;
  @override
  String get type => 'solid';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'color': color};
}

class GradientBackground extends BackgroundConfig {
  const GradientBackground({required this.angle, required this.stops});
  final double angle;
  final List<GradientStop> stops;
  @override
  String get type => 'gradient';
  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'angle': angle,
        'stops': stops.map((s) => s.toJson()).toList(),
      };
}

class GeometricBackground extends BackgroundConfig {
  const GeometricBackground({
    required this.seed,
    required this.palette,
    required this.density,
    required this.complexity,
    required this.style,
    this.presetId,
    this.shapeCount,
    this.useBrandColors,
    this.baseColor,
  });

  final int seed;
  final List<String> palette;
  final double density;
  final double complexity;
  final String style;
  final String? presetId;
  final int? shapeCount;
  final bool? useBrandColors;
  final String? baseColor;

  @override
  String get type => 'geometric';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'seed': seed,
        'palette': palette,
        'density': density,
        'complexity': complexity,
        'style': style,
        if (presetId != null) 'presetId': presetId,
        if (shapeCount != null) 'shapeCount': shapeCount,
        if (useBrandColors != null) 'useBrandColors': useBrandColors,
        if (baseColor != null) 'baseColor': baseColor,
      };
}

class ImageBackground extends BackgroundConfig {
  const ImageBackground({
    required this.assetId,
    required this.fit,
    required this.blur,
    required this.opacity,
  });
  final String assetId;
  final String fit;
  final double blur;
  final double opacity;
  @override
  String get type => 'image';
  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'assetId': assetId,
        'fit': fit,
        'blur': blur,
        'opacity': opacity,
      };
}

class GradientStop {
  const GradientStop({required this.color, required this.position});
  final String color;
  final double position;
  Map<String, dynamic> toJson() => {'color': color, 'position': position};
}

class TextEffects {
  const TextEffects({
    this.shadow,
    this.stroke,
    this.glow,
    this.gradientFill,
    this.backdrop,
    this.underline,
  });

  final Map<String, dynamic>? shadow;
  final Map<String, dynamic>? stroke;
  final Map<String, dynamic>? glow;
  final Map<String, dynamic>? gradientFill;
  final Map<String, dynamic>? backdrop;
  final Map<String, dynamic>? underline;

  Map<String, dynamic> toJson() => {
        if (shadow != null) 'shadow': shadow,
        if (stroke != null) 'stroke': stroke,
        if (glow != null) 'glow': glow,
        if (gradientFill != null) 'gradientFill': gradientFill,
        if (backdrop != null) 'backdrop': backdrop,
        if (underline != null) 'underline': underline,
      };

  factory TextEffects.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TextEffects();
    return TextEffects(
      shadow: _mapOrNull(json['shadow']),
      stroke: _mapOrNull(json['stroke']),
      glow: _mapOrNull(json['glow']),
      gradientFill: _mapOrNull(json['gradientFill']),
      backdrop: _mapOrNull(json['backdrop']),
      underline: _mapOrNull(json['underline']),
    );
  }
}

sealed class DesignElement {
  const DesignElement({
    required this.id,
    required this.type,
    required this.name,
    required this.transform,
    required this.zIndex,
    required this.locked,
    required this.visible,
    this.role,
  });

  final String id;
  final String type;
  final String name;
  final ElementTransform transform;
  final int zIndex;
  final bool locked;
  final bool visible;
  final String? role;

  DesignElement copyWithTransform(ElementTransform transform);
  Map<String, dynamic> toJson();

  factory DesignElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'shape';
    final base = (
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? type,
      transform: ElementTransform.fromJson(
        Map<String, dynamic>.from(json['transform'] as Map? ?? {}),
      ),
      zIndex: _i(json['zIndex']),
      locked: json['locked'] as bool? ?? false,
      visible: json['visible'] as bool? ?? true,
      role: json['role'] as String?,
    );
    switch (type) {
      case 'text':
        return TextElement(
          id: base.id,
          name: base.name,
          transform: base.transform,
          zIndex: base.zIndex,
          locked: base.locked,
          visible: base.visible,
          role: base.role,
          content: json['content'] as String? ?? '',
          fontFamily: json['fontFamily'] as String? ?? 'DM Sans',
          fontSize: _d(json['fontSize'], 32),
          fontWeight: _i(json['fontWeight'], 600),
          fontStyle: json['fontStyle'] as String? ?? 'normal',
          lineHeight: _d(json['lineHeight'], 1.12),
          letterSpacing: _d(json['letterSpacing']),
          color: json['color'] as String? ?? '#FFFFFF',
          align: json['align'] as String? ?? 'center',
          effects: TextEffects.fromJson(_mapOrNull(json['effects'])),
        );
      case 'image':
        return ImageElement(
          id: base.id,
          name: base.name,
          transform: base.transform,
          zIndex: base.zIndex,
          locked: base.locked,
          visible: base.visible,
          role: base.role,
          assetId: json['assetId'] as String? ?? '',
          fit: json['fit'] as String? ?? 'cover',
          borderRadius: _d(json['borderRadius']),
        );
      case 'logo':
        return LogoElement(
          id: base.id,
          name: base.name,
          transform: base.transform,
          zIndex: base.zIndex,
          locked: base.locked,
          visible: base.visible,
          role: base.role,
          assetId: json['assetId'] as String? ?? '',
          fit: json['fit'] as String? ?? 'contain',
        );
      case 'mockup':
        return MockupElement(
          id: base.id,
          name: base.name,
          transform: base.transform,
          zIndex: base.zIndex,
          locked: base.locked,
          visible: base.visible,
          role: base.role,
          screenAssetId: json['screenAssetId'] as String? ?? '',
          style: json['style'] as String? ?? 'full',
          deviceId: json['deviceId'] as String? ?? 'modern-iphone',
          frameColor: json['frameColor'] as String? ?? '#0B0B0F',
          fitMode: json['fitMode'] as String? ?? 'cover',
          coverFill: json['coverFill'] as String? ?? 'crop',
          cropOffsetX: _d(json['cropOffsetX'], 0.5),
          cropOffsetY: _d(json['cropOffsetY'], 0.5),
          padInsetX: json['padInsetX'] == null ? null : _d(json['padInsetX']),
          padInsetY: json['padInsetY'] == null ? null : _d(json['padInsetY']),
          padColor: json['padColor'] as String?,
          matchedAspect:
              json['matchedAspect'] == null ? null : _d(json['matchedAspect']),
          appearance: json['appearance'] as String? ?? 'dark',
          shadow: _mapOrNull(json['shadow']),
        );
      default:
        return ShapeElement(
          id: base.id,
          name: base.name,
          transform: base.transform,
          zIndex: base.zIndex,
          locked: base.locked,
          visible: base.visible,
          role: base.role,
          shape: json['shape'] as String? ?? 'rectangle',
          fill: json['fill'] as String? ?? '#FFFFFF',
          stroke: json['stroke'] as String?,
          strokeWidth: _d(json['strokeWidth']),
          points: (json['points'] as List?)
              ?.whereType<Map>()
              .map(
                (p) => Point2D(_d(p['x']), _d(p['y'])),
              )
              .toList(),
          cornerRadius:
              json['cornerRadius'] == null ? null : _d(json['cornerRadius']),
        );
    }
  }
}

class TextElement extends DesignElement {
  TextElement({
    required super.id,
    required super.name,
    required super.transform,
    required super.zIndex,
    required super.locked,
    required super.visible,
    super.role,
    required this.content,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.fontStyle,
    required this.lineHeight,
    required this.letterSpacing,
    required this.color,
    required this.align,
    required this.effects,
  }) : super(type: 'text');

  final String content;
  final String fontFamily;
  final double fontSize;
  final int fontWeight;
  final String fontStyle;
  final double lineHeight;
  final double letterSpacing;
  final String color;
  final String align;
  final TextEffects effects;

  TextElement copyWith({
    String? content,
    String? color,
    String? align,
    int? fontWeight,
    TextEffects? effects,
    ElementTransform? transform,
  }) {
    return TextElement(
      id: id,
      name: name,
      transform: transform ?? this.transform,
      zIndex: zIndex,
      locked: locked,
      visible: visible,
      role: role,
      content: content ?? this.content,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
      color: color ?? this.color,
      align: align ?? this.align,
      effects: effects ?? this.effects,
    );
  }

  @override
  DesignElement copyWithTransform(ElementTransform transform) =>
      copyWith(transform: transform);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'locked': locked,
        'visible': visible,
        if (role != null) 'role': role,
        'content': content,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'fontStyle': fontStyle,
        'lineHeight': lineHeight,
        'letterSpacing': letterSpacing,
        'color': color,
        'align': align,
        'effects': effects.toJson(),
      };
}

class ImageElement extends DesignElement {
  ImageElement({
    required super.id,
    required super.name,
    required super.transform,
    required super.zIndex,
    required super.locked,
    required super.visible,
    super.role,
    required this.assetId,
    required this.fit,
    required this.borderRadius,
  }) : super(type: 'image');

  final String assetId;
  final String fit;
  final double borderRadius;

  @override
  DesignElement copyWithTransform(ElementTransform transform) {
    return ImageElement(
      id: id,
      name: name,
      transform: transform,
      zIndex: zIndex,
      locked: locked,
      visible: visible,
      role: role,
      assetId: assetId,
      fit: fit,
      borderRadius: borderRadius,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'locked': locked,
        'visible': visible,
        if (role != null) 'role': role,
        'assetId': assetId,
        'fit': fit,
        'borderRadius': borderRadius,
      };
}

class LogoElement extends DesignElement {
  LogoElement({
    required super.id,
    required super.name,
    required super.transform,
    required super.zIndex,
    required super.locked,
    required super.visible,
    super.role,
    required this.assetId,
    required this.fit,
  }) : super(type: 'logo');

  final String assetId;
  final String fit;

  @override
  DesignElement copyWithTransform(ElementTransform transform) {
    return LogoElement(
      id: id,
      name: name,
      transform: transform,
      zIndex: zIndex,
      locked: locked,
      visible: visible,
      role: role,
      assetId: assetId,
      fit: fit,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'locked': locked,
        'visible': visible,
        if (role != null) 'role': role,
        'assetId': assetId,
        'fit': fit,
      };
}

class MockupElement extends DesignElement {
  MockupElement({
    required super.id,
    required super.name,
    required super.transform,
    required super.zIndex,
    required super.locked,
    required super.visible,
    super.role,
    required this.screenAssetId,
    required this.style,
    required this.deviceId,
    required this.frameColor,
    this.fitMode = 'cover',
    this.coverFill = 'crop',
    this.cropOffsetX = 0.5,
    this.cropOffsetY = 0.5,
    this.padInsetX,
    this.padInsetY,
    this.padColor,
    this.matchedAspect,
    this.appearance = 'dark',
    this.shadow,
  }) : super(type: 'mockup');

  final String screenAssetId;
  final String style;
  final String deviceId;
  final String frameColor;
  final String fitMode;
  final String coverFill;
  final double cropOffsetX;
  final double cropOffsetY;
  final double? padInsetX;
  final double? padInsetY;
  final String? padColor;
  final double? matchedAspect;
  final String appearance;
  final Map<String, dynamic>? shadow;

  MockupElement copyWith({
    String? screenAssetId,
    String? style,
    String? deviceId,
    String? frameColor,
    String? appearance,
    ElementTransform? transform,
  }) {
    return MockupElement(
      id: id,
      name: name,
      transform: transform ?? this.transform,
      zIndex: zIndex,
      locked: locked,
      visible: visible,
      role: role,
      screenAssetId: screenAssetId ?? this.screenAssetId,
      style: style ?? this.style,
      deviceId: deviceId ?? this.deviceId,
      frameColor: frameColor ?? this.frameColor,
      fitMode: fitMode,
      coverFill: coverFill,
      cropOffsetX: cropOffsetX,
      cropOffsetY: cropOffsetY,
      padInsetX: padInsetX,
      padInsetY: padInsetY,
      padColor: padColor,
      matchedAspect: matchedAspect,
      appearance: appearance ?? this.appearance,
      shadow: shadow,
    );
  }

  @override
  DesignElement copyWithTransform(ElementTransform transform) =>
      copyWith(transform: transform);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'locked': locked,
        'visible': visible,
        if (role != null) 'role': role,
        'screenAssetId': screenAssetId,
        'style': style,
        'deviceId': deviceId,
        'frameColor': frameColor,
        'fitMode': fitMode,
        'coverFill': coverFill,
        'cropOffsetX': cropOffsetX,
        'cropOffsetY': cropOffsetY,
        if (padInsetX != null) 'padInsetX': padInsetX,
        if (padInsetY != null) 'padInsetY': padInsetY,
        if (padColor != null) 'padColor': padColor,
        if (matchedAspect != null) 'matchedAspect': matchedAspect,
        'appearance': appearance,
        if (shadow != null) 'shadow': shadow,
      };
}

class ShapeElement extends DesignElement {
  ShapeElement({
    required super.id,
    required super.name,
    required super.transform,
    required super.zIndex,
    required super.locked,
    required super.visible,
    super.role,
    required this.shape,
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    this.points,
    this.cornerRadius,
  }) : super(type: 'shape');

  final String shape;
  final String fill;
  final String? stroke;
  final double strokeWidth;
  final List<Point2D>? points;
  final double? cornerRadius;

  @override
  DesignElement copyWithTransform(ElementTransform transform) {
    return ShapeElement(
      id: id,
      name: name,
      transform: transform,
      zIndex: zIndex,
      locked: locked,
      visible: visible,
      role: role,
      shape: shape,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
      points: points,
      cornerRadius: cornerRadius,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'transform': transform.toJson(),
        'zIndex': zIndex,
        'locked': locked,
        'visible': visible,
        if (role != null) 'role': role,
        'shape': shape,
        'fill': fill,
        'stroke': stroke,
        'strokeWidth': strokeWidth,
        if (points != null)
          'points': points!.map((p) => {'x': p.x, 'y': p.y}).toList(),
        if (cornerRadius != null) 'cornerRadius': cornerRadius,
      };
}

class DesignDocument {
  const DesignDocument({
    this.version = designDocumentVersion,
    required this.canvas,
    required this.background,
    required this.elements,
  });

  final int version;
  final CanvasConfig canvas;
  final BackgroundConfig background;
  final List<DesignElement> elements;

  DesignDocument copyWith({
    BackgroundConfig? background,
    List<DesignElement>? elements,
  }) {
    return DesignDocument(
      version: version,
      canvas: canvas,
      background: background ?? this.background,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'canvas': canvas.toJson(),
        'background': background.toJson(),
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory DesignDocument.fromJson(Map<String, dynamic> json) {
    return DesignDocument(
      version: _i(json['version'], designDocumentVersion),
      canvas: CanvasConfig.fromJson(
        Map<String, dynamic>.from(json['canvas'] as Map? ?? {}),
      ),
      background: BackgroundConfig.fromJson(
        Map<String, dynamic>.from(json['background'] as Map? ?? {}),
      ),
      elements: (json['elements'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DesignElement.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DesignMetaDocument {
  const DesignMetaDocument({
    this.version = designDocumentVersion,
    this.brandKitId,
    this.templateId,
    this.notes,
  });

  final int version;
  final String? brandKitId;
  final String? templateId;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'version': version,
        'brandKitId': brandKitId,
        'templateId': templateId,
        if (notes != null) 'notes': notes,
      };

  factory DesignMetaDocument.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DesignMetaDocument();
    }
    return DesignMetaDocument(
      version: _i(json['version'], designDocumentVersion),
      brandKitId: json['brandKitId'] as String?,
      templateId: json['templateId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

double _d(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return fallback;
}

int _i(Object? value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return fallback;
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}

List<GradientStop> _stops(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((s) {
    return GradientStop(
      color: s['color'] as String? ?? '#FFFFFF',
      position: _d(s['position']),
    );
  }).toList();
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

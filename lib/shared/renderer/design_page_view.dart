import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/hex.dart';
import '../../domain/document.dart';
import '../../domain/mockups.dart';

class DesignPageView extends StatelessWidget {
  const DesignPageView({
    super.key,
    required this.document,
    required this.assetUrls,
    this.showWatermark = false,
    this.missingFontWarning = false,
  });

  final DesignDocument document;
  final Map<String, String?> assetUrls;
  final bool showWatermark;
  final bool missingFontWarning;

  @override
  Widget build(BuildContext context) {
    final w = document.canvas.width.toDouble();
    final h = document.canvas.height.toDouble();
    final elements = [...document.elements]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundLayer(background: document.background, assetUrls: assetUrls),
            for (final el in elements)
              if (el.visible)
                _ElementLayer(element: el, assetUrls: assetUrls),
            if (showWatermark)
              const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(36),
                  child: Text(
                    'ShotKit',
                    style: TextStyle(
                      color: Color(0x66FFFFFF),
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FittedDesignPage extends StatelessWidget {
  const FittedDesignPage({
    super.key,
    required this.document,
    required this.assetUrls,
    this.showWatermark = false,
  });

  final DesignDocument document;
  final Map<String, String?> assetUrls;
  final bool showWatermark;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: DesignPageView(
        document: document,
        assetUrls: assetUrls,
        showWatermark: showWatermark,
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.background, required this.assetUrls});
  final BackgroundConfig background;
  final Map<String, String?> assetUrls;

  @override
  Widget build(BuildContext context) {
    if (background is SolidBackground) {
      return ColoredBox(color: parseHexColor((background as SolidBackground).color));
    }
    if (background is GradientBackground) {
      final g = background as GradientBackground;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _fromAngle(g.angle),
            end: _fromAngle(g.angle + 180),
            colors: g.stops.map((s) => parseHexColor(s.color)).toList(),
            stops: g.stops.map((s) => s.position.clamp(0.0, 1.0)).toList(),
          ),
        ),
      );
    }
    if (background is GeometricBackground) {
      final g = background as GeometricBackground;
      return ColoredBox(
        color: parseHexColor(g.baseColor ?? (g.palette.isNotEmpty ? g.palette.first : '#0F172A')),
      );
    }
    if (background is ImageBackground) {
      final img = background as ImageBackground;
      final url = assetUrls[img.assetId];
      if (url == null) return const ColoredBox(color: Color(0xFF0F172A));
      return Opacity(
        opacity: img.opacity,
        child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
      );
    }
    return const ColoredBox(color: Color(0xFF0F172A));
  }
}

Alignment _fromAngle(double degrees) {
  final rad = degrees * math.pi / 180;
  return Alignment(math.cos(rad), math.sin(rad));
}

class _ElementLayer extends StatelessWidget {
  const _ElementLayer({required this.element, required this.assetUrls});
  final DesignElement element;
  final Map<String, String?> assetUrls;

  @override
  Widget build(BuildContext context) {
    final t = element.transform;
    return Positioned(
      left: t.x,
      top: t.y,
      width: t.width,
      height: t.height,
      child: Opacity(
        opacity: t.opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: t.rotation * math.pi / 180,
          child: _paint(element),
        ),
      ),
    );
  }

  Widget _paint(DesignElement el) {
    if (el is TextElement) return _TextPaint(el);
    if (el is ShapeElement) return _ShapePaint(el);
    if (el is ImageElement) {
      return _AssetImage(url: assetUrls[el.assetId], fit: el.fit, radius: el.borderRadius);
    }
    if (el is LogoElement) {
      return _AssetImage(url: assetUrls[el.assetId], fit: el.fit, radius: 0);
    }
    if (el is MockupElement) {
      return _MockupPaint(element: el, url: assetUrls[el.screenAssetId]);
    }
    return const SizedBox.shrink();
  }
}

class _TextPaint extends StatelessWidget {
  const _TextPaint(this.el);
  final TextElement el;

  @override
  Widget build(BuildContext context) {
    final align = switch (el.align) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      _ => TextAlign.center,
    };
    final shadow = el.effects.shadow;
    final enabled = shadow?['enabled'] == true;
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        el.fontFamily,
        fontSize: el.fontSize,
        fontWeight: FontWeight.values.firstWhere(
          (w) => w.value == el.fontWeight,
          orElse: () => FontWeight.w600,
        ),
        fontStyle: el.fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
        color: parseHexColor(el.color),
        height: el.lineHeight,
        letterSpacing: el.letterSpacing,
        shadows: enabled
            ? [
                Shadow(
                  color: parseHexColor(shadow?['color'] as String? ?? '#000000'),
                  blurRadius: (shadow?['blur'] as num?)?.toDouble() ?? 12,
                  offset: Offset(
                    (shadow?['offsetX'] as num?)?.toDouble() ?? 0,
                    (shadow?['offsetY'] as num?)?.toDouble() ?? 6,
                  ),
                ),
              ]
            : null,
      );
    } catch (_) {
      style = TextStyle(
        fontFamily: 'DM Sans',
        fontSize: el.fontSize,
        fontWeight: FontWeight.w600,
        color: parseHexColor(el.color),
        height: el.lineHeight,
      );
    }

    final backdrop = el.effects.backdrop;
    final child = Text(el.content, textAlign: align, style: style);
    if (backdrop?['enabled'] == true) {
      return Container(
        alignment: switch (el.align) {
          'left' => Alignment.centerLeft,
          'right' => Alignment.centerRight,
          _ => Alignment.center,
        },
        padding: EdgeInsets.fromLTRB(
          (backdrop?['paddingLeft'] as num?)?.toDouble() ??
              (backdrop?['paddingX'] as num?)?.toDouble() ??
              12,
          (backdrop?['paddingTop'] as num?)?.toDouble() ??
              (backdrop?['paddingY'] as num?)?.toDouble() ??
              6,
          (backdrop?['paddingRight'] as num?)?.toDouble() ??
              (backdrop?['paddingX'] as num?)?.toDouble() ??
              12,
          (backdrop?['paddingBottom'] as num?)?.toDouble() ??
              (backdrop?['paddingY'] as num?)?.toDouble() ??
              6,
        ),
        decoration: BoxDecoration(
          color: parseHexColor(backdrop?['color'] as String? ?? '#000000')
              .withValues(alpha: (backdrop?['opacity'] as num?)?.toDouble() ?? 0.5),
          borderRadius: BorderRadius.circular(
            (backdrop?['borderRadius'] as num?)?.toDouble() ?? 8,
          ),
        ),
        child: child,
      );
    }
    return Align(
      alignment: switch (el.align) {
        'left' => Alignment.centerLeft,
        'right' => Alignment.centerRight,
        _ => Alignment.center,
      },
      child: child,
    );
  }
}

class _ShapePaint extends StatelessWidget {
  const _ShapePaint(this.el);
  final ShapeElement el;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(el.fill);
    final radius = el.cornerRadius ?? 0;
    switch (el.shape) {
      case 'ellipse':
      case 'blob':
        return DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      default:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: el.stroke == null
                ? null
                : Border.all(color: parseHexColor(el.stroke!), width: el.strokeWidth),
          ),
        );
    }
  }
}

class _AssetImage extends StatelessWidget {
  const _AssetImage({required this.url, required this.fit, required this.radius});
  final String? url;
  final String fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const ColoredBox(color: Color(0x22000000));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: switch (fit) {
          'contain' => BoxFit.contain,
          'fill' => BoxFit.fill,
          _ => BoxFit.cover,
        },
      ),
    );
  }
}

class _MockupPaint extends StatelessWidget {
  const _MockupPaint({required this.element, required this.url});
  final MockupElement element;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final def = mockupById(element.deviceId);
    if (element.style == 'none') {
      return _AssetImage(url: url, fit: 'cover', radius: 24);
    }

    final insetT = def?.insetTop ?? 0.016;
    final insetR = def?.insetRight ?? 0.016;
    final insetB = def?.insetBottom ?? 0.016;
    final insetL = def?.insetLeft ?? 0.016;
    final frameR = (def?.cornerRadius ?? 0.12) * math.min(
      element.transform.width,
      element.transform.height,
    );
    final screenR = (def?.screenCornerRadius ?? 0.1) *
        math.min(element.transform.width, element.transform.height);
    final shadow = element.shadow;
    final shadowOn = shadow?['enabled'] != false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(frameR),
        boxShadow: shadowOn
            ? [
                BoxShadow(
                  color: parseHexColor(shadow?['color'] as String? ?? '#000000')
                      .withValues(
                    alpha: (shadow?['opacity'] as num?)?.toDouble() ?? 0.32,
                  ),
                  blurRadius: (shadow?['blur'] as num?)?.toDouble() ?? 36,
                  offset: Offset(
                    (shadow?['offsetX'] as num?)?.toDouble() ?? 0,
                    (shadow?['offsetY'] as num?)?.toDouble() ?? 20,
                  ),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(frameR),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: parseHexColor(element.frameColor)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                element.transform.width * insetL,
                element.transform.height * insetT,
                element.transform.width * insetR,
                element.transform.height * insetB,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenR),
                child: url == null
                    ? const ColoredBox(color: Color(0xFF111827))
                    : CachedNetworkImage(
                        imageUrl: url!,
                        fit: switch (element.fitMode) {
                          'contain' => BoxFit.contain,
                          'stretch' => BoxFit.fill,
                          _ => BoxFit.cover,
                        },
                        alignment: Alignment(
                          (element.cropOffsetX - 0.5) * 2,
                          (element.cropOffsetY - 0.5) * 2,
                        ),
                      ),
              ),
            ),
            if (def != null && def.cameraType != 'none')
              Align(
                alignment: Alignment(0, -1 + def.cameraTop * 2),
                child: Container(
                  width: element.transform.width * def.cameraWidth,
                  height: element.transform.height * def.cameraHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      def.cameraType == 'punch-hole' ? 99 : 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

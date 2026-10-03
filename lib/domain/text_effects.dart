import 'document.dart';

const defaultTextEffects = TextEffects(
  shadow: {
    'enabled': false,
    'color': '#000000',
    'opacity': 0.45,
    'blur': 8,
    'offsetX': 0,
    'offsetY': 4,
  },
  stroke: {
    'enabled': false,
    'color': '#000000',
    'width': 2,
  },
  glow: {
    'enabled': false,
    'color': '#FFFFFF',
    'blur': 12,
    'intensity': 0.6,
  },
  gradientFill: {
    'enabled': false,
    'angle': 90,
    'stops': [
      {'color': '#FFFFFF', 'position': 0},
      {'color': '#A1A1AA', 'position': 1},
    ],
  },
  backdrop: {
    'enabled': false,
    'style': 'none',
    'color': '#000000',
    'paddingX': 16,
    'paddingY': 8,
    'paddingTop': 8,
    'paddingRight': 16,
    'paddingBottom': 8,
    'paddingLeft': 16,
    'borderRadius': 8,
    'opacity': 0.55,
  },
  underline: {
    'enabled': false,
    'color': '#FACC15',
    'thickness': 0.3,
    'offset': 0.1,
    'opacity': 0.85,
    'rounded': true,
  },
);

Map<String, dynamic> _merge(
  Map<String, dynamic>? base,
  Map<String, dynamic>? patch,
) {
  return {...?base, ...?patch};
}

TextEffects normalizeTextEffects(TextEffects? effects) {
  if (effects == null) return defaultTextEffects;
  final backdrop = _merge(defaultTextEffects.backdrop, effects.backdrop);
  backdrop['paddingTop'] =
      effects.backdrop?['paddingTop'] ??
      effects.backdrop?['paddingY'] ??
      defaultTextEffects.backdrop!['paddingTop'];
  backdrop['paddingBottom'] =
      effects.backdrop?['paddingBottom'] ??
      effects.backdrop?['paddingY'] ??
      defaultTextEffects.backdrop!['paddingBottom'];
  backdrop['paddingLeft'] =
      effects.backdrop?['paddingLeft'] ??
      effects.backdrop?['paddingX'] ??
      defaultTextEffects.backdrop!['paddingLeft'];
  backdrop['paddingRight'] =
      effects.backdrop?['paddingRight'] ??
      effects.backdrop?['paddingX'] ??
      defaultTextEffects.backdrop!['paddingRight'];
  return TextEffects(
    shadow: _merge(defaultTextEffects.shadow, effects.shadow),
    stroke: _merge(defaultTextEffects.stroke, effects.stroke),
    glow: _merge(defaultTextEffects.glow, effects.glow),
    gradientFill: _merge(defaultTextEffects.gradientFill, effects.gradientFill),
    backdrop: backdrop,
    underline: _merge(defaultTextEffects.underline, effects.underline),
  );
}

class TextEffectPreset {
  const TextEffectPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.apply,
  });

  final String id;
  final String name;
  final String description;
  final TextElement Function(TextElement element) apply;
}

TextEffects _effects(Map<String, Map<String, dynamic>> patch) {
  return normalizeTextEffects(
    TextEffects(
      shadow: patch['shadow'],
      stroke: patch['stroke'],
      glow: patch['glow'],
      gradientFill: patch['gradientFill'],
      backdrop: patch['backdrop'],
      underline: patch['underline'],
    ),
  );
}

final textEffectPresets = <TextEffectPreset>[
  TextEffectPreset(
    id: 'clean',
    name: 'Clean',
    description: 'Minimal type with no effects.',
    apply: (el) => el.copyWith(
      fontWeight: 600,
      effects: _effects({
        'shadow': {'enabled': false},
        'stroke': {'enabled': false},
        'glow': {'enabled': false},
        'gradientFill': {'enabled': false},
        'backdrop': {'enabled': false},
        'underline': {'enabled': false},
      }),
    ),
  ),
  TextEffectPreset(
    id: 'bold',
    name: 'Bold',
    description: 'Heavy weight with soft depth.',
    apply: (el) => el.copyWith(
      fontWeight: 800,
      effects: _effects({
        'shadow': {
          'enabled': true,
          'color': '#000000',
          'opacity': 0.35,
          'blur': 18,
          'offsetX': 0,
          'offsetY': 10,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'outline',
    name: 'Outline',
    description: 'Strong stroke for high contrast.',
    apply: (el) => el.copyWith(
      color: '#FFFFFF',
      fontWeight: 800,
      effects: _effects({
        'stroke': {
          'enabled': true,
          'color': '#0F172A',
          'width': (el.fontSize * 0.04).round().clamp(2, 24),
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'soft-shadow',
    name: 'Soft Shadow',
    description: 'Gentle drop shadow.',
    apply: (el) => el.copyWith(
      effects: _effects({
        'shadow': {
          'enabled': true,
          'color': '#000000',
          'opacity': 0.4,
          'blur': 24,
          'offsetX': 0,
          'offsetY': 12,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'glow',
    name: 'Glow',
    description: 'Soft luminous glow.',
    apply: (el) => el.copyWith(
      effects: _effects({
        'glow': {
          'enabled': true,
          'color': '#38BDF8',
          'blur': 28,
          'intensity': 0.75,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'highlight',
    name: 'Highlight',
    description: 'Underline marker highlight.',
    apply: (el) => el.copyWith(
      effects: _effects({
        'underline': {
          'enabled': true,
          'color': '#FACC15',
          'thickness': 0.35,
          'offset': 0.12,
          'opacity': 0.85,
          'rounded': true,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'gradient',
    name: 'Gradient',
    description: 'Linear gradient fill.',
    apply: (el) => el.copyWith(
      effects: _effects({
        'gradientFill': {
          'enabled': true,
          'angle': 120,
          'stops': [
            {'color': '#FFFFFF', 'position': 0},
            {'color': '#93C5FD', 'position': 1},
          ],
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'instagram-strip',
    name: 'Instagram Strip',
    description: 'Solid horizontal text strip.',
    apply: (el) => el.copyWith(
      color: '#FFFFFF',
      fontWeight: 700,
      effects: _effects({
        'backdrop': {
          'enabled': true,
          'style': 'strip',
          'color': '#E11D48',
          'paddingX': 28,
          'paddingY': 14,
          'paddingTop': 14,
          'paddingRight': 32,
          'paddingBottom': 14,
          'paddingLeft': 32,
          'borderRadius': 0,
          'opacity': 1,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'instagram-rounded',
    name: 'Instagram Rounded',
    description: 'Rounded pill highlight.',
    apply: (el) => el.copyWith(
      color: '#0F172A',
      fontWeight: 700,
      effects: _effects({
        'backdrop': {
          'enabled': true,
          'style': 'rounded',
          'color': '#F8FAFC',
          'paddingX': 24,
          'paddingY': 12,
          'paddingTop': 12,
          'paddingRight': 28,
          'paddingBottom': 12,
          'paddingLeft': 28,
          'borderRadius': 999,
          'opacity': 0.95,
        },
      }),
    ),
  ),
  TextEffectPreset(
    id: 'strong-contrast',
    name: 'Strong Contrast',
    description: 'Dark strip with outline.',
    apply: (el) => el.copyWith(
      color: '#FFFFFF',
      fontWeight: 800,
      effects: _effects({
        'stroke': {'enabled': true, 'color': '#000000', 'width': 1},
        'shadow': {
          'enabled': true,
          'color': '#000000',
          'opacity': 0.5,
          'blur': 12,
          'offsetX': 0,
          'offsetY': 6,
        },
        'backdrop': {
          'enabled': true,
          'style': 'strip',
          'color': '#0F172A',
          'paddingX': 24,
          'paddingY': 12,
          'paddingTop': 12,
          'paddingRight': 28,
          'paddingBottom': 12,
          'paddingLeft': 28,
          'borderRadius': 4,
          'opacity': 0.9,
        },
      }),
    ),
  ),
];

TextEffectPreset? getTextEffectPreset(String id) {
  for (final preset in textEffectPresets) {
    if (preset.id == id) return preset;
  }
  return null;
}

TextElement applyTextEffectPreset(TextElement element, String presetId) {
  return getTextEffectPreset(presetId)?.apply(element) ?? element;
}

bool _flag(Map<String, dynamic>? map, String key) => map?[key] == true;

String? matchedTextEffectPresetId(TextElement element) {
  final effects = normalizeTextEffects(element.effects);
  final shadow = _flag(effects.shadow, 'enabled');
  final stroke = _flag(effects.stroke, 'enabled');
  final glow = _flag(effects.glow, 'enabled');
  final gradient = _flag(effects.gradientFill, 'enabled');
  final backdrop = _flag(effects.backdrop, 'enabled');
  final underline = _flag(effects.underline, 'enabled');
  final style = effects.backdrop?['style'] as String?;

  if (!shadow && !stroke && !glow && !gradient && !backdrop && !underline) {
    return 'clean';
  }
  if (backdrop && style == 'strip' && stroke) return 'strong-contrast';
  if (backdrop && style == 'strip') return 'instagram-strip';
  if (backdrop && style == 'rounded') return 'instagram-rounded';
  if (underline && !backdrop) return 'highlight';
  if (gradient) return 'gradient';
  if (glow && !stroke && !backdrop) return 'glow';
  if (stroke && !backdrop) return 'outline';
  if (shadow && element.fontWeight >= 800 && !stroke && !glow) return 'bold';
  if (shadow && !stroke && !glow && !backdrop) return 'soft-shadow';
  return null;
}

DesignDocument applyTextEffectPresetToDocument(
  DesignDocument document,
  String presetId,
) {
  final texts = document.elements.whereType<TextElement>();
  final hasHeading = texts.any(
    (el) => el.role == 'heading' || el.name == 'Headline',
  );
  return document.copyWith(
    elements: document.elements.map((el) {
      if (el is! TextElement) return el;
      if (hasHeading && el.role != 'heading' && el.name != 'Headline') {
        return el;
      }
      return applyTextEffectPreset(el, presetId);
    }).toList(),
  );
}

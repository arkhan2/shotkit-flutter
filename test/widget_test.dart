import 'package:flutter_test/flutter_test.dart';

import 'package:shotkit/domain/canvas.dart';
import 'package:shotkit/domain/compliance.dart';
import 'package:shotkit/domain/document.dart';

void main() {
  test('iPhone 6.9 preset matches store size', () {
    final preset = canvasPresetById('iphone_6_9');
    expect(preset, isNotNull);
    expect(preset!.width, 1320);
    expect(preset.height, 2868);
  });

  test('DesignDocument round-trips JSON', () {
    final document = DesignDocument(
      canvas: const CanvasConfig(
        presetId: 'iphone_6_9',
        platform: 'app_store',
        deviceType: 'iphone_6_9',
        width: 1320,
        height: 2868,
      ),
      background: const SolidBackground(color: '#0F172A'),
      elements: [
        TextElement(
          id: 't1',
          name: 'Headline',
          transform: const ElementTransform(x: 0, y: 0, width: 100, height: 40),
          zIndex: 1,
          locked: false,
          visible: true,
          content: 'Hello',
          fontFamily: 'DM Sans',
          fontSize: 32,
          fontWeight: 600,
          fontStyle: 'normal',
          lineHeight: 1.1,
          letterSpacing: 0,
          color: '#FFFFFF',
          align: 'center',
          effects: const TextEffects(),
        ),
      ],
    );
    final parsed = DesignDocument.fromJson(document.toJson());
    expect(parsed.canvas.width, 1320);
    expect(parsed.elements, hasLength(1));
    expect((parsed.elements.first as TextElement).content, 'Hello');
  });

  test('filename helper sanitizes segments', () {
    expect(
      buildPageFilename(sortIndex: 0, pageName: 'Home Screen', extension: 'png'),
      '01-home-screen.png',
    );
  });
}

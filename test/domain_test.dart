import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/domain/canvas.dart';
import 'package:shotkit/domain/document.dart';
import 'package:shotkit/domain/entitlements.dart';
import 'package:shotkit/domain/generate.dart';
import 'package:shotkit/domain/templates.dart';

void main() {
  test('every system template builds a valid document', () {
    final canvas = CanvasConfig(
      presetId: 'iphone_6_9',
      platform: 'app_store',
      deviceType: 'iphone_6_9',
      width: 1320,
      height: 2868,
    );
    for (final template in systemTemplates) {
      final doc = generatePageFromTemplate(
        template: template,
        canvas: canvas,
        screenAssetId: 'screen-1',
        secondaryScreenAssetId: 'screen-2',
      );
      expect(doc.canvas.width, 1320);
      expect(doc.elements, isNotEmpty);
      expect(doc.toJson()['version'], 1);
    }
  });

  test('compliance rules exist for every canvas preset', () {
    for (final preset in canvasPresets) {
      expect(canvasPresetById(preset.id), isNotNull);
    }
  });

  test('free plan currently includes watermark-free export', () {
    final snap = buildEntitlementSnapshot(
      planId: 'free',
      status: 'none',
      resources: const ResourceUsage(
        projects: 0,
        designs: 0,
        brandKits: 0,
        fonts: 0,
      ),
    );
    expect(shouldApplyExportWatermark(snap), isFalse);
    expect(canExport(snap).ok, isTrue);
  });
}

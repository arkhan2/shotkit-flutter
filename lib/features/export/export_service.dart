import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

import '../../core/result.dart';
import '../../domain/compliance.dart';
import '../../domain/document.dart';
import '../../domain/models.dart';
import '../../shared/renderer/design_page_view.dart';
import '../../shared/renderer/render_ready.dart';

class ExportArtifact {
  const ExportArtifact({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class ExportService {
  Future<Result<ExportArtifact>> rasterizePage({
    required BuildContext context,
    required DesignDocument document,
    required Map<String, String?> assetUrls,
    required String format,
    required String fileName,
    bool watermark = false,
    int jpegQuality = 92,
  }) async {
    if (!context.mounted) return const Err('Export cancelled.');
    await waitForRendererAssets(
      context,
      assetUrls,
      fontFamilies: fontFamiliesInDocument(document),
    );
    if (!context.mounted) return const Err('Export cancelled.');

    final key = GlobalKey();
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -4000,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: key,
            child: DesignPageView(
              document: document,
              assetUrls: assetUrls,
              showWatermark: watermark,
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!context.mounted) {
      entry.remove();
      return const Err('Export cancelled.');
    }
    await waitForRendererAssets(
      context,
      assetUrls,
      fontFamilies: fontFamiliesInDocument(document),
    );
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 200));

    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return const Err('Could not render the page.');
      }
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return const Err('Failed to encode the page.');

      var data = bytes.buffer.asUint8List();
      var mime = 'image/png';
      if (format == 'jpeg') {
        final decoded = img.decodePng(data);
        if (decoded == null) return const Err('Failed to encode JPEG.');
        data = img.encodeJpg(decoded, quality: jpegQuality);
        mime = 'image/jpeg';
      }

      return Ok(
        ExportArtifact(bytes: data, fileName: fileName, mimeType: mime),
      );
    } catch (e) {
      return Err(e.toString());
    } finally {
      entry.remove();
    }
  }

  Future<Result<ExportArtifact>> zipArtifacts(
    List<ExportArtifact> artifacts,
    String zipName,
  ) async {
    try {
      final archive = Archive();
      for (final artifact in artifacts) {
        archive.addFile(
          ArchiveFile(artifact.fileName, artifact.bytes.length, artifact.bytes),
        );
      }
      final encoded = ZipEncoder().encode(archive);
      return Ok(
        ExportArtifact(
          bytes: Uint8List.fromList(encoded),
          fileName: zipName,
          mimeType: 'application/zip',
        ),
      );
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> saveToPhotos(ExportArtifact artifact) async {
    if (artifact.mimeType == 'application/zip') {
      await shareArtifacts([artifact]);
      return const Ok(null);
    }
    if (kIsWeb) {
      await shareArtifacts([artifact]);
      return const Ok(null);
    }
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return const Err('Photo library permission is required to save exports.');
        }
      }
      await Gal.putImageBytes(artifact.bytes, name: artifact.fileName);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<void> shareArtifacts(List<ExportArtifact> artifacts) async {
    await SharePlus.instance.share(
      ShareParams(
        files: artifacts
            .map(
              (artifact) => XFile.fromData(
                artifact.bytes,
                name: artifact.fileName,
                mimeType: artifact.mimeType,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<Result<List<ExportArtifact>>> exportDesign({
    required BuildContext context,
    required Design design,
    required List<DesignPage> pages,
    required Map<String, String?> assetUrls,
    required String format,
    required String scope,
    required bool watermark,
    int jpegQuality = 92,
  }) async {
    final targets = scope == 'current' && pages.isNotEmpty ? [pages.first] : pages;
    final artifacts = <ExportArtifact>[];
    for (final page in targets) {
      final name = buildPageFilename(
        sortIndex: page.sortOrder,
        pageName: page.name,
        extension: format,
      );
      final result = await rasterizePage(
        context: context,
        document: page.document,
        assetUrls: assetUrls,
        format: format,
        fileName: name,
        watermark: watermark,
        jpegQuality: jpegQuality,
      );
      if (result is Err<ExportArtifact>) return Err(result.message);
      artifacts.add((result as Ok<ExportArtifact>).data);
    }

    if (scope == 'zip') {
      final zip = await zipArtifacts(
        artifacts,
        buildZipFilename(designName: design.name, platform: design.platform),
      );
      if (zip is Err<ExportArtifact>) return Err(zip.message);
      return Ok([zip.dataOrNull!]);
    }
    return Ok(artifacts);
  }
}

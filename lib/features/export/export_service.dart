import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/result.dart';
import '../../domain/compliance.dart';
import '../../domain/document.dart';
import '../../domain/models.dart';
import '../../shared/renderer/design_page_view.dart';

class ExportService {
  Future<Result<File>> rasterizePage({
    required BuildContext context,
    required DesignDocument document,
    required Map<String, String?> assetUrls,
    required String format,
    required String fileName,
    bool watermark = false,
    int jpegQuality = 92,
  }) async {
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
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 200));

    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return const Err('Could not render the page.');
      }
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return const Err('Failed to encode the page.');

      var data = bytes.buffer.asUint8List();
      if (format == 'jpeg') {
        final decoded = img.decodePng(data);
        if (decoded == null) return const Err('Failed to encode JPEG.');
        data = img.encodeJpg(decoded, quality: jpegQuality);
      }

      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(data, flush: true);
      return Ok(file);
    } catch (e) {
      return Err(e.toString());
    } finally {
      entry.remove();
    }
  }

  Future<Result<File>> zipFiles(List<File> files, String zipName) async {
    try {
      final archive = Archive();
      for (final file in files) {
        archive.addFile(
          ArchiveFile(p.basename(file.path), file.lengthSync(), file.readAsBytesSync()),
        );
      }
      final bytes = ZipEncoder().encode(archive);
      final dir = await getTemporaryDirectory();
      final out = File(p.join(dir.path, zipName));
      await out.writeAsBytes(bytes, flush: true);
      return Ok(out);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> saveToPhotos(File file) async {
    try {
      await Gal.putImage(file.path);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<void> shareFiles(List<File> files) async {
    await SharePlus.instance.share(
      ShareParams(files: files.map((f) => XFile(f.path)).toList()),
    );
  }

  Future<Result<List<File>>> exportDesign({
    required BuildContext context,
    required Design design,
    required List<DesignPage> pages,
    required Map<String, String?> assetUrls,
    required String format,
    required String scope,
    required bool watermark,
    int jpegQuality = 92,
  }) async {
    final targets = scope == 'current' && pages.isNotEmpty
        ? [pages.first]
        : pages;
    final files = <File>[];
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
      if (result is Err<File>) return Err(result.message);
      files.add((result as Ok<File>).data);
    }

    if (scope == 'zip') {
      final zip = await zipFiles(
        files,
        buildZipFilename(designName: design.name, platform: design.platform),
      );
      if (zip is Err<File>) return Err(zip.message);
      return Ok([zip.dataOrNull!]);
    }
    return Ok(files);
  }
}

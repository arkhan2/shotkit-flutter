import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/document.dart';

Iterable<String> fontFamiliesInDocument(DesignDocument document) {
  return document.elements.whereType<TextElement>().map((el) => el.fontFamily);
}

Future<void> waitForRendererAssets(
  BuildContext context,
  Map<String, String?> assetUrls, {
  Iterable<String> fontFamilies = const [],
}) async {
  for (final url in assetUrls.values) {
    if (url == null || url.isEmpty) continue;
    try {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }
  for (final family in fontFamilies.toSet()) {
    try {
      GoogleFonts.getFont(family);
    } catch (_) {}
  }
  try {
    await GoogleFonts.pendingFonts();
  } catch (_) {}
  await WidgetsBinding.instance.endOfFrame;
}

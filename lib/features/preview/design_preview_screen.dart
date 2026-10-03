import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../domain/document.dart';
import '../../domain/models.dart';
import '../../domain/platforms.dart';
import '../../shared/renderer/design_page_view.dart';
import '../../shared/widgets.dart';
import '../export/export_sheet.dart';

class DesignPreviewScreen extends ConsumerStatefulWidget {
  const DesignPreviewScreen({super.key, required this.designId});
  final String designId;

  @override
  ConsumerState<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends ConsumerState<DesignPreviewScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Design, List<DesignPage>, Map<String, String?>)?>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              title: 'Preview unavailable',
              message: snapshot.error?.toString() ?? 'Design not found.',
            ),
          );
        }
        final design = snapshot.data!.$1;
        final pages = snapshot.data!.$2;
        final urls = snapshot.data!.$3;
        final page = pages[_index.clamp(0, pages.length - 1)];
        return Scaffold(
          appBar: AppBar(
            title: Text(design.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => context.push('/app/designs/${design.id}/compose'),
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                tooltip: 'Export',
                onPressed: () => showExportSheet(
                  context,
                  design: design,
                  pages: pages,
                  assetUrls: urls,
                  currentIndex: _index,
                ),
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  '${platformLabels[design.platform] ?? design.platform} · ${deviceTypeLabels[design.deviceType] ?? design.deviceType} · ${design.width}×${design.height}',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: FittedDesignPage(document: page.document, assetUrls: urls),
                  ),
                ),
              ),
              SizedBox(
                height: 72,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _index == 0 ? null : () => setState(() => _index--),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('${_index + 1} / ${pages.length}'),
                    IconButton(
                      onPressed: _index >= pages.length - 1 ? null : () => setState(() => _index++),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<(Design, List<DesignPage>, Map<String, String?>)?> _load() async {
    final design = await ref.read(designRepositoryProvider).getDesign(widget.designId);
    if (design == null) return null;
    final pages = await ref.read(designRepositoryProvider).listPages(widget.designId);
    final ids = <String>{};
    for (final page in pages) {
      for (final el in page.document.elements) {
        if (el is MockupElement) ids.add(el.screenAssetId);
        if (el is LogoElement) ids.add(el.assetId);
        if (el is ImageElement) ids.add(el.assetId);
      }
    }
    final urls = await ref.read(screenRepositoryProvider).signedUrlsForAssetIds(ids);
    return (design, pages, urls);
  }
}

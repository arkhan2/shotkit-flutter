import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../domain/document.dart';
import '../../domain/generate.dart';
import '../../domain/layouts.dart';
import '../../domain/mockups.dart';
import '../../domain/models.dart';
import '../../domain/text_effects.dart';
import '../../shared/renderer/design_page_view.dart';
import '../../shared/widgets.dart';
import '../export/export_sheet.dart';

class ComposerReviewScreen extends ConsumerStatefulWidget {
  const ComposerReviewScreen({super.key, required this.designId});
  final String designId;

  @override
  ConsumerState<ComposerReviewScreen> createState() => _ComposerReviewScreenState();
}

class _ComposerReviewScreenState extends ConsumerState<ComposerReviewScreen> {
  int _index = 0;
  String _saveStatus = 'Saved';
  bool _loading = true;
  String? _error;
  Design? _design;
  List<DesignPage> _pages = [];
  Map<String, String?> _urls = {};
  BrandKitWithColors? _kit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final design = await ref.read(designRepositoryProvider).getDesign(widget.designId);
      if (design == null) {
        setState(() {
          _loading = false;
          _error = 'Design not found.';
        });
        return;
      }
      final pages = await ref.read(designRepositoryProvider).listPages(widget.designId);
      final ids = <String>{};
      for (final page in pages) {
        for (final el in page.document.elements) {
          if (el is MockupElement) ids.add(el.screenAssetId);
          if (el is LogoElement || el is ImageElement) {
            ids.add(el is LogoElement ? el.assetId : (el as ImageElement).assetId);
          }
        }
      }
      final urls = await ref.read(screenRepositoryProvider).signedUrlsForAssetIds(ids);
      BrandKitWithColors? kit;
      if (design.document.brandKitId != null) {
        kit = await ref.read(brandKitRepositoryProvider).getKit(design.document.brandKitId!);
      }
      setState(() {
        _design = design;
        _pages = pages;
        _urls = urls;
        _kit = kit;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  DesignPage get _page => _pages[_index];

  Future<void> _commit(DesignDocument document) async {
    setState(() {
      _pages = [
        for (var i = 0; i < _pages.length; i++)
          if (i == _index)
            DesignPage(
              id: _page.id,
              designId: _page.designId,
              sortOrder: _page.sortOrder,
              name: _page.name,
              document: document,
              documentVersion: document.version,
            )
          else
            _pages[i],
      ];
      _saveStatus = 'Saving';
    });
    final result = await ref.read(designRepositoryProvider).updatePageDocument(
          pageId: _page.id,
          document: document,
        );
    if (!mounted) return;
    setState(() => _saveStatus = result.isOk ? 'Saved' : 'Unsaved');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _design == null || _pages.isEmpty) {
      return Scaffold(
        appBar: const ShotKitAppBar(),
        body: EmptyState(title: 'Cannot open design', message: _error ?? 'No pages.'),
      );
    }

    return Scaffold(
      appBar: ShotKitAppBar(
        title: _design!.name,
        actions: [
          Text(_saveStatus, style: Theme.of(context).textTheme.labelMedium),
          IconButton(
            tooltip: 'Preview',
            onPressed: () => context.push('/app/designs/${widget.designId}'),
            icon: const Icon(Icons.visibility_outlined),
          ),
          IconButton(
            tooltip: 'Export',
            onPressed: () => showExportSheet(
              context,
              design: _design!,
              pages: _pages,
              assetUrls: _urls,
              currentIndex: _index,
            ),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Center(
                child: FittedDesignPage(
                  document: _page.document,
                  assetUrls: _urls,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _pages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _index;
                return ChoiceChip(
                  selected: selected,
                  label: Text(_pages[index].name ?? 'Page ${index + 1}'),
                  onSelected: (_) => setState(() => _index = index),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip('Text', Icons.title, _editText),
                  _Chip('Style', Icons.auto_awesome, _editStyle),
                  _Chip('Layout', Icons.dashboard_customize_outlined, _editLayout),
                  _Chip('Background', Icons.gradient, _editBackground),
                  _Chip('Brand', Icons.palette_outlined, _editBrand),
                  _Chip('Mockup', Icons.phone_iphone, _editMockup),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editText() async {
    final texts = _page.document.elements.whereType<TextElement>().toList();
    final heading = texts.cast<TextElement?>().firstWhere(
          (t) => t!.role == 'heading' || t.name == 'Headline',
          orElse: () => texts.firstOrNull,
        );
    final body = texts.cast<TextElement?>().firstWhere(
          (t) => t!.role == 'body' || t.name == 'Body',
          orElse: () => null,
        );
    final headingCtrl = TextEditingController(text: heading?.content ?? '');
    final bodyCtrl = TextEditingController(text: body?.content ?? '');
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: headingCtrl, decoration: const InputDecoration(labelText: 'Headline'), maxLines: 2),
            if (body != null) ...[
              const SizedBox(height: 12),
              TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Body')),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await _commit(
        applyTextEdits(
          _page.document,
          heading: headingCtrl.text,
          body: body == null ? null : bodyCtrl.text,
        ),
      );
    }
  }

  Future<void> _editStyle() async {
    final heading = _page.document.elements.whereType<TextElement>().cast<TextElement?>().firstWhere(
          (t) => t!.role == 'heading' || t.name == 'Headline',
          orElse: () => _page.document.elements.whereType<TextElement>().firstOrNull,
        );
    if (heading == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a headline before applying a style.')),
      );
      return;
    }
    final selectedId = matchedTextEffectPresetId(heading);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Text styles', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Same effect presets as ShotKit studio. Applied to the headline.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            for (final preset in textEffectPresets)
              ListTile(
                contentPadding: EdgeInsets.zero,
                selected: preset.id == selectedId,
                title: Text(preset.name),
                subtitle: Text(preset.description),
                trailing: preset.id == selectedId
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, preset.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    await _commit(applyTextEffectPresetToDocument(_page.document, selected));
  }

  Future<void> _editLayout() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final recipe in layoutRecipes)
            ListTile(
              title: Text(recipe.name),
              subtitle: Text(recipe.category),
              onTap: () => Navigator.pop(context, recipe.id),
            ),
        ],
      ),
    );
    if (selected == null) return;
    final mockups = _page.document.elements.whereType<MockupElement>().toList();
    await _commit(
      applyLayoutRecipe(
        source: _page.document,
        recipeId: selected,
        primaryScreenAssetId: mockups.firstOrNull?.screenAssetId ?? '',
        secondaryScreenAssetId: mockups.length > 1 ? mockups[1].screenAssetId : null,
        logoAssetId: _kit?.resolvedLogoAssetId,
      ),
    );
  }

  Future<void> _editBackground() async {
    final current = _page.document.background;
    var solid = current is SolidBackground ? current.color : '#0F172A';
    var start = current is GradientBackground && current.stops.isNotEmpty
        ? current.stops.first.color
        : '#0F172A';
    var end = current is GradientBackground && current.stops.length > 1
        ? current.stops.last.color
        : '#1D4ED8';
    var mode = current.type;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'solid', label: Text('Solid')),
                ButtonSegment(value: 'gradient', label: Text('Gradient')),
              ],
              selected: {mode == 'gradient' ? 'gradient' : 'solid'},
              onSelectionChanged: (value) => mode = value.first,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: solid),
              decoration: const InputDecoration(labelText: 'Solid / start hex'),
              onChanged: (v) {
                solid = v;
                start = v;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: end),
              decoration: const InputDecoration(labelText: 'Gradient end hex'),
              onChanged: (v) => end = v,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    await _commit(
      applySolidOrGradientBackground(
        _page.document,
        mode == 'gradient'
            ? GradientBackground(
                angle: 160,
                stops: [
                  GradientStop(color: start, position: 0),
                  GradientStop(color: end, position: 1),
                ],
              )
            : SolidBackground(color: solid),
      ),
    );
  }

  Future<void> _editBrand() async {
    if (_kit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attach a Brand Kit on the project to apply colors.')),
      );
      return;
    }
    await _commit(applyBrandColorsToDocument(_page.document, _kit!));
  }

  Future<void> _editMockup() async {
    final selected = await showModalBottomSheet<(String, String)>(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final mockup in mockupCatalog)
            ListTile(
              title: Text(mockup.name),
              subtitle: Text(mockup.description),
              onTap: () => Navigator.pop(context, (mockup.id, 'full')),
              trailing: TextButton(
                onPressed: () => Navigator.pop(context, (mockup.id, 'cropped')),
                child: const Text('Cropped'),
              ),
            ),
        ],
      ),
    );
    if (selected == null) return;
    await _commit(
      applyMockupStyle(_page.document, deviceId: selected.$1, style: selected.$2),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

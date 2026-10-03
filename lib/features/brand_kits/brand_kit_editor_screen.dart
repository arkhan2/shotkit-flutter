import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/hex.dart';
import '../../data/providers.dart';
import '../../domain/brand.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import 'brand_kits_screen.dart';

class BrandKitEditorScreen extends ConsumerStatefulWidget {
  const BrandKitEditorScreen({super.key, required this.kitId});
  final String kitId;

  @override
  ConsumerState<BrandKitEditorScreen> createState() => _BrandKitEditorScreenState();
}

class _BrandKitEditorScreenState extends ConsumerState<BrandKitEditorScreen> {
  final _name = TextEditingController();
  final _colorName = TextEditingController(text: 'Primary');
  final _colorHex = TextEditingController(text: '#38BDF8');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _colorName.dispose();
    _colorHex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kits = ref.watch(brandKitsProvider);
    return kits.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: EmptyState(title: 'Error', message: e.toString())),
      data: (items) {
        BrandKitWithColors? kit;
        for (final item in items) {
          if (item.kit.id == widget.kitId) kit = item;
        }
        if (kit == null) {
          return const Scaffold(body: EmptyState(title: 'Not found', message: 'Brand Kit missing.'));
        }
        if (_name.text.isEmpty) _name.text = kit.kit.name;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Brand Kit'),
            actions: [
              IconButton(
                onPressed: () async {
                  await ref.read(brandKitRepositoryProvider).deleteKit(widget.kitId);
                  ref.invalidate(brandKitsProvider);
                  if (context.mounted) context.go('/app/brand-kits');
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSubmitted: (value) async {
                  await ref.read(brandKitRepositoryProvider).renameKit(widget.kitId, value);
                  ref.invalidate(brandKitsProvider);
                },
              ),
              const SizedBox(height: 24),
              const SectionLabel('Logos'),
              const SizedBox(height: 4),
              Text(
                'Light for pale backgrounds, dark for deep ones.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppBrand.slate,
                    ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 12),
              _LogoSlot(
                label: 'Light logo',
                url: kit.logoLightUrl ?? kit.logoUrl,
                darkPreview: false,
                busy: _busy,
                onAdd: () => _logo('light'),
                onRemove: () => _removeLogo('light'),
              ),
              const SizedBox(height: 12),
              _LogoSlot(
                label: 'Dark logo',
                url: kit.logoDarkUrl,
                darkPreview: true,
                busy: _busy,
                onAdd: () => _logo('dark'),
                onRemove: () => _removeLogo('dark'),
              ),
              const SizedBox(height: 24),
              const SectionLabel('Colors'),
              const SizedBox(height: 8),
              for (final color in kit.colors)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: parseHexColor(color.hex)),
                  title: Text(color.name),
                  subtitle: Text(color.hex),
                  trailing: IconButton(
                    onPressed: () async {
                      await ref.read(brandKitRepositoryProvider).deleteColor(color.id);
                      ref.invalidate(brandKitsProvider);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _colorName,
                decoration: const InputDecoration(labelText: 'Color name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _colorHex,
                decoration: const InputDecoration(labelText: 'Hex'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(brandKitRepositoryProvider).addColor(
                        brandKitId: widget.kitId,
                        name: _colorName.text,
                        hex: _colorHex.text,
                      );
                  ref.invalidate(brandKitsProvider);
                },
                child: const Text('Add color'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logo(String variant) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(brandKitRepositoryProvider).uploadLogo(
          brandKitId: widget.kitId,
          file: File(file.path),
          variant: variant,
        );
    if (!mounted) return;
    result.when(
      ok: (_) => ref.invalidate(brandKitsProvider),
      err: (message) => setState(() => _error = message),
    );
    setState(() => _busy = false);
  }

  Future<void> _removeLogo(String variant) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(brandKitRepositoryProvider).removeLogo(
          brandKitId: widget.kitId,
          variant: variant,
        );
    if (!mounted) return;
    result.when(
      ok: (_) => ref.invalidate(brandKitsProvider),
      err: (message) => setState(() => _error = message),
    );
    setState(() => _busy = false);
  }
}

class _LogoSlot extends StatelessWidget {
  const _LogoSlot({
    required this.label,
    required this.url,
    required this.darkPreview,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String? url;
  final bool darkPreview;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasLogo = url != null && url!.isNotEmpty;
    final previewColor = darkPreview ? AppBrand.deep : Colors.white;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: previewColor,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: hasLogo
                      ? CachedNetworkImage(
                          imageUrl: url!,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          Icons.image_outlined,
                          color: AppBrand.slate.withValues(alpha: 0.7),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    hasLogo ? 'Added to this kit' : 'None yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppBrand.slate,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy ? null : onAdd,
                          child: Text(hasLogo ? 'Replace' : 'Add'),
                        ),
                      ),
                      if (hasLogo) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: busy ? null : onRemove,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/hex.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

final brandKitsProvider = FutureProvider<List<BrandKitWithColors>>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(brandKitRepositoryProvider).listKits();
});

class BrandKitsScreen extends ConsumerWidget {
  const BrandKitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kits = ref.watch(brandKitsProvider);
    return Scaffold(
      appBar: ShotKitAppBar(
        title: 'Brand Kits',
        actions: [
          IconButton(
            onPressed: () => context.push('/app/brand-kits/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: kits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          title: 'Could not load Brand Kits',
          message: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(brandKitsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'No Brand Kits',
              message: 'Save a logo and colors once, then apply them to every design.',
              actionLabel: 'Create Brand Kit',
              onAction: () => context.push('/app/brand-kits/new'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final kit = items[index];
              return Card(
                child: ListTile(
                  title: Text(kit.kit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        for (final color in kit.colors.take(6))
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: parseHexColor(color.hex),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/app/brand-kits/${kit.kit.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewBrandKitScreen extends ConsumerStatefulWidget {
  const NewBrandKitScreen({super.key});

  @override
  ConsumerState<NewBrandKitScreen> createState() => _NewBrandKitScreenState();
}

class _NewBrandKitScreenState extends ConsumerState<NewBrandKitScreen> {
  final _name = TextEditingController(text: 'My Brand Kit');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShotKitAppBar(title: 'New Brand Kit'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_error != null) ErrorBanner(_error!),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      final result =
                          await ref.read(brandKitRepositoryProvider).createKit(_name.text);
                      if (!context.mounted) return;
                      result.when(
                        ok: (kit) {
                          ref.invalidate(brandKitsProvider);
                          context.go('/app/brand-kits/${kit.id}');
                        },
                        err: (message) => setState(() {
                          _busy = false;
                          _error = message;
                        }),
                      );
                    },
              child: Text(_busy ? 'Creating…' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

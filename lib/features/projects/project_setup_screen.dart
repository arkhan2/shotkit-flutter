import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../brand_kits/brand_kits_screen.dart';
import 'project_detail_screen.dart';
import 'projects_screen.dart';

class ProjectSetupScreen extends ConsumerWidget {
  const ProjectSetupScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final screens = ref.watch(projectScreensProvider(projectId));
    final kits = ref.watch(brandKitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Project setup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('1. App screens', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Upload the captures you want in the store listing.'),
          const SizedBox(height: 12),
          screens.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (items) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final screen in items)
                  _ScreenTile(
                    screen: screen,
                    onDelete: () async {
                      await ref.read(screenRepositoryProvider).deleteScreen(screen);
                      ref.invalidate(projectScreensProvider(projectId));
                      ref.invalidate(projectsProvider);
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                  onPressed: () => _pick(ref, ImageSource.gallery),
                ),
                ActionChip(
                  avatar: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Camera'),
                  onPressed: () => _pick(ref, ImageSource.camera),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('2. Brand Kit', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Optional. Colors and logos apply when you generate pages.'),
          const SizedBox(height: 12),
          kits.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (items) {
              final selected = project.valueOrNull?.brandKitId;
              return Column(
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Attached kit'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final kit in items)
                        DropdownMenuItem(value: kit.kit.id, child: Text(kit.kit.name)),
                    ],
                    onChanged: (value) async {
                      await ref.read(projectRepositoryProvider).updateProject(
                            id: projectId,
                            brandKitId: value,
                            clearBrandKit: value == null,
                          );
                      ref.invalidate(projectProvider(projectId));
                      ref.invalidate(projectsProvider);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.push('/app/brand-kits/new'),
                      child: const Text('Create Brand Kit'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text('3. Start designing', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: screens.valueOrNull?.isNotEmpty == true
                ? () => context.push('/app/projects/$projectId/compose')
                : null,
            child: const Text('Choose size and template'),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage(imageQuality: 95);
      for (final file in files) {
        await ref.read(screenRepositoryProvider).uploadScreen(
              projectId: projectId,
              file: File(file.path),
            );
      }
    } else {
      final file = await picker.pickImage(source: source, imageQuality: 95);
      if (file == null) return;
      await ref.read(screenRepositoryProvider).uploadScreen(
            projectId: projectId,
            file: File(file.path),
          );
    }
    ref.invalidate(projectScreensProvider(projectId));
    ref.invalidate(projectsProvider);
  }
}

class _ScreenTile extends StatelessWidget {
  const _ScreenTile({required this.screen, required this.onDelete});
  final AppScreen screen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 9 / 19.5,
              child: screen.previewUrl == null
                  ? const ColoredBox(color: Color(0x11000000))
                  : CachedNetworkImage(imageUrl: screen.previewUrl!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

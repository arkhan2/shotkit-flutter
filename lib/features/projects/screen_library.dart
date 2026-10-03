import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/providers.dart';
import '../../domain/models.dart';
import 'project_detail_screen.dart';
import 'projects_screen.dart';

Future<void> pickAndUploadScreens(
  WidgetRef ref, {
  required String projectId,
  ImageSource source = ImageSource.gallery,
}) async {
  final picker = ImagePicker();
  final files = source == ImageSource.gallery
      ? await picker.pickMultiImage(imageQuality: 95)
      : [
          ?await picker.pickImage(source: source, imageQuality: 95),
        ];
  if (files.isEmpty) return;
  final repo = ref.read(screenRepositoryProvider);
  for (final file in files) {
    await repo.uploadScreenBytes(
      projectId: projectId,
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
  }
  ref.invalidate(projectScreensProvider(projectId));
  ref.invalidate(projectsProvider);
}

Future<void> renameScreenDialog(
  BuildContext context,
  WidgetRef ref, {
  required AppScreen screen,
}) async {
  final controller = TextEditingController(text: screen.name ?? '');
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename screen'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == screen.name) return;
  await ref.read(screenRepositoryProvider).renameScreen(screen.id, trimmed);
  ref.invalidate(projectScreensProvider(screen.projectId));
}

class ScreenStrip extends ConsumerWidget {
  const ScreenStrip({super.key, required this.projectId, required this.screens});

  final String projectId;
  final List<AppScreen> screens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (screens.isEmpty) {
      return const Text('No screens yet. Add captures from camera or gallery.');
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: screens.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final screen = screens[index];
          return SizedBox(
            width: 76,
            child: InkWell(
              onTap: () => renameScreenDialog(context, ref, screen: screen),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: screen.previewUrl == null
                          ? const ColoredBox(color: Color(0x11000000))
                          : CachedNetworkImage(
                              imageUrl: screen.previewUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    screen.name ?? 'Screen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScreenReorderList extends ConsumerStatefulWidget {
  const ScreenReorderList({
    super.key,
    required this.projectId,
    required this.screens,
  });

  final String projectId;
  final List<AppScreen> screens;

  @override
  ConsumerState<ScreenReorderList> createState() => _ScreenReorderListState();
}

class _ScreenReorderListState extends ConsumerState<ScreenReorderList> {
  late List<AppScreen> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.screens);
  }

  @override
  void didUpdateWidget(covariant ScreenReorderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screens != widget.screens) {
      _items = List.of(widget.screens);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Text('No screens yet. Add captures from camera or gallery.');
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
        await ref.read(screenRepositoryProvider).reorderScreens(_items);
        ref.invalidate(projectScreensProvider(widget.projectId));
      },
      itemBuilder: (context, index) {
        final screen = _items[index];
        return ListTile(
          key: ValueKey(screen.id),
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 72,
              child: screen.previewUrl == null
                  ? const ColoredBox(color: Color(0x11000000))
                  : CachedNetworkImage(
                      imageUrl: screen.previewUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          title: Text(screen.name ?? 'Screen ${index + 1}'),
          subtitle: const Text('Tap to rename · drag to reorder'),
          onTap: () => renameScreenDialog(context, ref, screen: screen),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  await ref.read(screenRepositoryProvider).deleteScreen(screen);
                  ref.invalidate(projectScreensProvider(widget.projectId));
                  ref.invalidate(projectsProvider);
                },
                icon: const Icon(Icons.close),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScreenAddButtons extends ConsumerWidget {
  const ScreenAddButtons({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.photo_library_outlined, size: 18),
          label: const Text('Gallery'),
          onPressed: () => pickAndUploadScreens(
            ref,
            projectId: projectId,
          ),
        ),
        ActionChip(
          avatar: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('Camera'),
          onPressed: () => pickAndUploadScreens(
            ref,
            projectId: projectId,
            source: ImageSource.camera,
          ),
        ),
      ],
    );
  }
}

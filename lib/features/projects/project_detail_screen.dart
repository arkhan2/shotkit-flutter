import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../domain/platforms.dart';
import '../../shared/widgets.dart';
import 'projects_screen.dart';
import 'screen_library.dart';

final projectProvider = FutureProvider.family<Project?, String>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProject(id);
});

final projectScreensProvider = FutureProvider.family<List<AppScreen>, String>((ref, id) {
  return ref.watch(screenRepositoryProvider).listScreens(id);
});

final projectDesignsProvider = FutureProvider.family<List<Design>, String>((ref, id) {
  return ref.watch(designRepositoryProvider).listDesigns(id);
});

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final screens = ref.watch(projectScreensProvider(projectId));
    final designs = ref.watch(projectDesignsProvider(projectId));

    return Scaffold(
      appBar: ShotKitAppBar(
        title: project.valueOrNull?.name ?? 'Project',
        actions: [
          IconButton(
            tooltip: 'Setup',
            onPressed: () => context.push('/app/projects/$projectId/setup'),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Delete project',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete project?'),
                  content: const Text('This removes the project, screens, and designs.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(projectRepositoryProvider).deleteProject(projectId);
                ref.invalidate(projectsProvider);
                if (context.mounted) context.go('/app');
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          project.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (value) {
              if (value == null) return const ErrorBanner('Project not found.');
              return Text(
                value.description?.isNotEmpty == true
                    ? value.description!
                    : 'Upload screens, attach a Brand Kit, then start designing.',
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: SectionLabel('App screens')),
              TextButton.icon(
                onPressed: () => pickAndUploadScreens(ref, projectId: projectId),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a screen to rename. Reorder in Setup.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          screens.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (items) => ScreenStrip(projectId: projectId, screens: items),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: SectionLabel('Designs')),
              TextButton.icon(
                onPressed: screens.valueOrNull?.isNotEmpty == true
                    ? () => context.push('/app/projects/$projectId/compose')
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('New design'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          designs.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBanner(e.toString()),
            data: (items) {
              if (items.isEmpty) {
                return const Text('No designs yet. Generate a set from your screens.');
              }
              return Column(
                children: [
                  for (final design in items)
                    Card(
                      child: ListTile(
                        title: Text(design.name),
                        subtitle: Text(
                          '${platformLabels[design.platform] ?? design.platform} · ${deviceTypeLabels[design.deviceType] ?? design.deviceType}',
                          maxLines: 2,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/app/designs/${design.id}'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

final projectsProvider = FutureProvider<List<ProjectListItem>>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(projectRepositoryProvider).listProjects();
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    return Scaffold(
      appBar: ShotKitAppBar(
        actions: [
          IconButton(
            onPressed: () => context.push('/app/projects/new'),
            icon: const Icon(Icons.add),
            tooltip: 'Create project',
          ),
        ],
      ),
      body: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          title: 'Could not load projects',
          message: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(projectsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'No projects yet',
              message: 'Create a project, upload screens, and generate a store-ready set.',
              actionLabel: 'Create project',
              onAction: () => context.push('/app/projects/new'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(projectsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = items[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      [
                        '${project.screenCount} screens',
                        if (project.brandKitName != null) project.brandKitName!,
                      ].join(' · '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/app/projects/${project.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

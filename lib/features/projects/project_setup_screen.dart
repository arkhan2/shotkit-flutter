import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../shared/widgets.dart';
import '../brand_kits/brand_kits_screen.dart';
import 'project_detail_screen.dart';
import 'projects_screen.dart';
import 'screen_library.dart';

class ProjectSetupScreen extends ConsumerWidget {
  const ProjectSetupScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final screens = ref.watch(projectScreensProvider(projectId));
    final kits = ref.watch(brandKitsProvider);

    return Scaffold(
      appBar: const ShotKitAppBar(title: 'Project setup'),
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
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenReorderList(projectId: projectId, screens: items),
                const SizedBox(height: 8),
                ScreenAddButtons(projectId: projectId),
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

}

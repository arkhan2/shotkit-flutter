import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validators.dart';
import '../../data/providers.dart';
import '../../shared/widgets.dart';
import 'projects_screen.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nameError = validateProjectName(_name.text);
    if (nameError != null) {
      setState(() => _error = nameError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(projectRepositoryProvider).createProject(
          name: _name.text,
          description: _description.text,
        );
    if (!mounted) return;
    result.when(
      ok: (project) {
        ref.invalidate(projectsProvider);
        context.go('/app/projects/${project.id}/setup');
      },
      err: (message) => setState(() {
        _busy = false;
        _error = message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShotKitAppBar(title: 'New project'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) ...[
            ErrorBanner(_error!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Project name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Creating…' : 'Continue'),
          ),
        ],
      ),
    );
  }
}

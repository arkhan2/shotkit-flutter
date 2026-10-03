import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validators.dart';
import '../../data/providers.dart';
import '../../domain/canvas.dart';
import '../../domain/models.dart';
import '../../domain/entitlements.dart';
import '../../domain/platforms.dart';
import '../../domain/templates.dart';
import '../../shared/widgets.dart';
import '../brand_kits/brand_kits_screen.dart';
import '../projects/project_detail_screen.dart';

class ComposerWizardScreen extends ConsumerStatefulWidget {
  const ComposerWizardScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<ComposerWizardScreen> createState() => _ComposerWizardScreenState();
}

class _ComposerWizardScreenState extends ConsumerState<ComposerWizardScreen> {
  String _platform = 'app_store';
  String _presetId = 'iphone_6_9';
  String _templateId = 'system_bold_headline';
  late final TextEditingController _name;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Store screenshots');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = canvasPresetsFor(_platform);
    return Scaffold(
      appBar: AppBar(title: const Text('New design')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) ...[
            ErrorBanner(_error!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Design name'),
          ),
          const SizedBox(height: 20),
          const SectionLabel('Platform'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              for (final platform in platforms)
                ButtonSegment(value: platform, label: Text(platformLabels[platform]!)),
            ],
            selected: {_platform},
            onSelectionChanged: (value) {
              final platform = value.first;
              final next = canvasPresetsFor(platform).first;
              setState(() {
                _platform = platform;
                _presetId = next.id;
              });
            },
          ),
          const SizedBox(height: 20),
          const SectionLabel('Canvas size'),
          const SizedBox(height: 8),
          for (final preset in presets)
            RadioListTile<String>(
              value: preset.id,
              groupValue: _presetId,
              title: Text(preset.label),
              subtitle: Text('${preset.width} × ${preset.height}'),
              onChanged: (value) => setState(() => _presetId = value!),
            ),
          const SizedBox(height: 12),
          const SectionLabel('Template'),
          const SizedBox(height: 8),
          for (final template in systemTemplates)
            RadioListTile<String>(
              value: template.id,
              groupValue: _templateId,
              title: Text(template.name),
              subtitle: Text(template.description),
              onChanged: (value) => setState(() => _templateId = value!),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _generate,
            child: Text(_busy ? 'Generating…' : 'Generate pages'),
          ),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final nameError = validateDesignName(_name.text);
    if (nameError != null) {
      setState(() => _error = nameError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final project = await ref.read(projectRepositoryProvider).getProject(widget.projectId);
    final entitlements = await ref.read(billingRepositoryProvider).snapshot();
    final designCheck = canCreateDesign(entitlements);
    if (!designCheck.ok) {
      setState(() {
        _busy = false;
        _error = designCheck.message;
      });
      return;
    }
    final templateCheck = isTemplateAllowed(entitlements, _templateId);
    if (!templateCheck.ok) {
      setState(() {
        _busy = false;
        _error = templateCheck.message;
      });
      return;
    }
    BrandKitWithColors? kit;
    if (project?.brandKitId != null) {
      final kits = await ref.read(brandKitsProvider.future);
      kit = kits.cast<BrandKitWithColors?>().firstWhere(
            (item) => item!.kit.id == project!.brandKitId,
            orElse: () => null,
          );
    }
    final result = await ref.read(designRepositoryProvider).createFromTemplate(
          projectId: widget.projectId,
          name: _name.text,
          canvasPresetId: _presetId,
          templateId: _templateId,
          screens: ref.read(screenRepositoryProvider),
          kits: ref.read(brandKitRepositoryProvider),
          brandKit: kit,
        );
    if (!mounted) return;
    result.when(
      ok: (data) {
        ref.invalidate(projectDesignsProvider(widget.projectId));
        context.go('/app/designs/${data.design.id}/compose');
      },
      err: (message) => setState(() {
        _busy = false;
        _error = message;
      }),
    );
  }
}

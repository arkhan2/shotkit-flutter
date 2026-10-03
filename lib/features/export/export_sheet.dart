import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/compliance.dart';
import '../../domain/entitlements.dart';
import '../../domain/models.dart';
import 'export_service.dart';

Future<void> showExportSheet(
  BuildContext context, {
  required Design design,
  required List<DesignPage> pages,
  required Map<String, String?> assetUrls,
  required int currentIndex,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ExportSheet(
      design: design,
      pages: pages,
      assetUrls: assetUrls,
      currentIndex: currentIndex,
    ),
  );
}

class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({
    super.key,
    required this.design,
    required this.pages,
    required this.assetUrls,
    required this.currentIndex,
  });

  final Design design;
  final List<DesignPage> pages;
  final Map<String, String?> assetUrls;
  final int currentIndex;

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  String _format = 'png';
  String _scope = 'all';
  bool _busy = false;
  String? _status;
  late ComplianceReport _report;

  @override
  void initState() {
    super.initState();
    _report = evaluateCompliance(
      design: widget.design,
      pages: widget.pages,
      format: _format,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(_report.presetDisplayName),
          const SizedBox(height: 16),
          for (final issue in _report.issues)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                issue.severity == 'error'
                    ? Icons.error_outline
                    : issue.severity == 'warning'
                        ? Icons.warning_amber_outlined
                        : Icons.check_circle_outline,
              ),
              title: Text(issue.title),
              subtitle: Text(issue.message),
            ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'png', label: Text('PNG')),
              ButtonSegment(value: 'jpeg', label: Text('JPEG')),
            ],
            selected: {_format},
            onSelectionChanged: (value) {
              setState(() {
                _format = value.first;
                _report = evaluateCompliance(
                  design: widget.design,
                  pages: widget.pages,
                  format: _format,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'current', label: Text('This page')),
              ButtonSegment(value: 'all', label: Text('All pages')),
              ButtonSegment(value: 'zip', label: Text('ZIP')),
            ],
            selected: {_scope},
            onSelectionChanged: (value) => setState(() => _scope = value.first),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : () => _run(savePhotos: true),
            child: Text(_busy ? 'Exporting…' : 'Save to Photos'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(savePhotos: false),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _run({required bool savePhotos}) async {
    if (_report.hasErrors) {
      final anyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export anyway?'),
          content: const Text('This set has compliance errors.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Export'),
            ),
          ],
        ),
      );
      if (anyway != true) return;
    }

    setState(() {
      _busy = true;
      _status = 'Checking entitlements…';
    });
    final billing = ref.read(billingRepositoryProvider);
    final snapshot = await billing.snapshot();
    final allowed = canExport(snapshot);
    if (!allowed.ok) {
      setState(() {
        _busy = false;
        _status = allowed.message;
      });
      return;
    }
    final claimed = await billing.claimExport(snapshot.limits.maxExportsPerMonth);
    if (claimed.isErr) {
      setState(() {
        _busy = false;
        _status = claimed.errorOrNull;
      });
      return;
    }

    var shouldRelease = true;
    try {
      setState(() => _status = 'Rendering…');
      final pages = _scope == 'current'
          ? [widget.pages[widget.currentIndex.clamp(0, widget.pages.length - 1)]]
          : widget.pages;
      final service = ExportService();
      if (!mounted) return;
      final result = await service.exportDesign(
        context: context,
        design: widget.design,
        pages: pages,
        assetUrls: widget.assetUrls,
        format: _format,
        scope: _scope,
        watermark: shouldApplyExportWatermark(snapshot),
      );
      if (result.isErr) {
        setState(() => _status = result.errorOrNull);
        return;
      }
      final files = result.dataOrNull!;
      if (savePhotos) {
        for (final file in files) {
          final saved = await service.saveToPhotos(file);
          if (saved.isErr) {
            setState(() => _status = saved.errorOrNull);
            return;
          }
        }
        setState(() => _status = 'Saved.');
      } else {
        await service.shareArtifacts(files);
        setState(() => _status = 'Shared.');
      }
      shouldRelease = false;
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (shouldRelease) {
        await billing.releaseExport();
      }
      if (mounted) setState(() => _busy = false);
    }
  }
}

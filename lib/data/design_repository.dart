import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/result.dart';
import '../core/validators.dart';
import '../domain/canvas.dart';
import '../domain/document.dart';
import '../domain/generate.dart';
import '../domain/models.dart';
import '../domain/templates.dart';
import 'brand_kit_repository.dart';
import 'mappers.dart';
import 'screen_repository.dart';

class DesignRepository {
  DesignRepository(this._client);
  final SupabaseClient _client;

  Future<List<Design>> listDesigns(String projectId) async {
    final rows = await _client
        .from('designs')
        .select()
        .eq('project_id', projectId)
        .order('updated_at', ascending: false);
    final designs = (rows as List).cast<Map<String, dynamic>>().map(mapDesign);
    final result = <Design>[];
    for (final design in designs) {
      final count = await _client
          .from('design_pages')
          .select('id')
          .eq('design_id', design.id);
      result.add(
        Design(
          id: design.id,
          projectId: design.projectId,
          name: design.name,
          platform: design.platform,
          deviceType: design.deviceType,
          width: design.width,
          height: design.height,
          document: design.document,
          documentVersion: design.documentVersion,
          createdAt: design.createdAt,
          updatedAt: design.updatedAt,
          pageCount: (count as List).length,
        ),
      );
    }
    return result;
  }

  Future<Design?> getDesign(String id) async {
    final row = await _client.from('designs').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return mapDesign(Map<String, dynamic>.from(row));
  }

  Future<List<DesignPage>> listPages(String designId) async {
    final rows = await _client
        .from('design_pages')
        .select()
        .eq('design_id', designId)
        .order('sort_order');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(mapDesignPage)
        .toList();
  }

  Future<Result<({Design design, List<DesignPage> pages})>> createFromTemplate({
    required String projectId,
    required String name,
    required String canvasPresetId,
    required String templateId,
    required ScreenRepository screens,
    required BrandKitRepository kits,
    BrandKitWithColors? brandKit,
  }) async {
    final nameError = validateDesignName(name);
    if (nameError != null) return Err(nameError);
    final preset = canvasPresetById(canvasPresetId);
    if (preset == null) return const Err('Choose a valid canvas size.');
    final template = systemTemplateById(templateId);
    if (template == null) return const Err('Choose a valid template.');

    final screenList = await screens.listScreens(projectId);
    if (screenList.isEmpty) {
      return const Err('Upload at least one app screenshot first.');
    }

    final canvas = CanvasConfig(
      presetId: preset.id,
      platform: preset.platform,
      deviceType: preset.deviceType,
      width: preset.width,
      height: preset.height,
    );
    final meta = DesignMetaDocument(
      brandKitId: brandKit?.kit.id,
      templateId: template.id,
    );

    try {
      final designRow = await _client
          .from('designs')
          .insert({
            'project_id': projectId,
            'name': name.trim(),
            'platform': preset.platform,
            'device_type': preset.deviceType,
            'width': preset.width,
            'height': preset.height,
            'document': meta.toJson(),
            'document_version': designDocumentVersion,
          })
          .select()
          .single();
      final design = mapDesign(Map<String, dynamic>.from(designRow));
      final pages = <DesignPage>[];

      for (var i = 0; i < screenList.length; i++) {
        final screen = screenList[i];
        final secondary = i + 1 < screenList.length ? screenList[i + 1] : screenList.first;
        final document = generatePageFromTemplate(
          template: template,
          canvas: canvas,
          screenAssetId: screen.assetId,
          secondaryScreenAssetId: secondary.assetId,
          brandKit: brandKit,
        );
        final pageRow = await _client
            .from('design_pages')
            .insert({
              'design_id': design.id,
              'sort_order': i,
              'name': screen.name ?? 'Page ${i + 1}',
              'document': document.toJson(),
              'document_version': designDocumentVersion,
            })
            .select()
            .single();
        pages.add(mapDesignPage(Map<String, dynamic>.from(pageRow)));
      }

      try {
        await _client.rpc('bump_usage_counter', params: {'p_field': 'designs_created'});
      } catch (_) {}

      return Ok((design: design, pages: pages));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> updatePageDocument({
    required String pageId,
    required DesignDocument document,
  }) async {
    try {
      await _client.from('design_pages').update({
        'document': document.toJson(),
        'document_version': document.version,
      }).eq('id', pageId);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> deleteDesign(String id) async {
    try {
      await _client.from('designs').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

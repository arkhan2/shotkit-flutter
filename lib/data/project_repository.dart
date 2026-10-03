import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/result.dart';
import '../core/validators.dart';
import '../domain/models.dart';
import 'mappers.dart';

class ProjectRepository {
  ProjectRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not authenticated');
    return id;
  }

  Future<List<ProjectListItem>> listProjects() async {
    final rows = await _client
        .from('projects')
        .select()
        .eq('user_id', _uid)
        .order('updated_at', ascending: false);
    final projects = (rows as List).cast<Map<String, dynamic>>();
    if (projects.isEmpty) return const [];

    final ids = projects.map((p) => p['id'] as String).toList();
    final kitIds = projects
        .map((p) => p['brand_kit_id'] as String?)
        .whereType<String>()
        .toList();

    final screens = await _client
        .from('app_screens')
        .select('project_id')
        .inFilter('project_id', ids);

    final counts = <String, int>{};
    for (final row in (screens as List).cast<Map<String, dynamic>>()) {
      final id = row['project_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }

    final kitNames = <String, String>{};
    if (kitIds.isNotEmpty) {
      final kits = await _client
          .from('brand_kits')
          .select('id, name')
          .inFilter('id', kitIds);
      for (final row in (kits as List).cast<Map<String, dynamic>>()) {
        kitNames[row['id'] as String] = row['name'] as String;
      }
    }

    return projects.map((row) {
      final project = mapProject(row);
      return ProjectListItem(
        id: project.id,
        userId: project.userId,
        name: project.name,
        description: project.description,
        brandKitId: project.brandKitId,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
        screenCount: counts[project.id] ?? 0,
        brandKitName:
            project.brandKitId == null ? null : kitNames[project.brandKitId],
      );
    }).toList();
  }

  Future<Project?> getProject(String id) async {
    final row = await _client
        .from('projects')
        .select()
        .eq('id', id)
        .eq('user_id', _uid)
        .maybeSingle();
    if (row == null) return null;
    return mapProject(Map<String, dynamic>.from(row));
  }

  Future<Result<Project>> createProject({
    required String name,
    String? description,
    String? brandKitId,
  }) async {
    final error = validateProjectName(name);
    if (error != null) return Err(error);
    try {
      final row = await _client
          .from('projects')
          .insert({
            'user_id': _uid,
            'name': name.trim(),
            'description': description?.trim().isEmpty == true
                ? null
                : description?.trim(),
            'brand_kit_id': brandKitId,
          })
          .select()
          .single();
      return Ok(mapProject(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<Project>> updateProject({
    required String id,
    String? name,
    String? description,
    String? brandKitId,
    bool clearBrandKit = false,
  }) async {
    if (name != null) {
      final error = validateProjectName(name);
      if (error != null) return Err(error);
    }
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name.trim();
      if (description != null) {
        payload['description'] =
            description.trim().isEmpty ? null : description.trim();
      }
      if (clearBrandKit) {
        payload['brand_kit_id'] = null;
      } else if (brandKitId != null) {
        payload['brand_kit_id'] = brandKitId;
      }
      final row = await _client
          .from('projects')
          .update(payload)
          .eq('id', id)
          .eq('user_id', _uid)
          .select()
          .single();
      return Ok(mapProject(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> deleteProject(String id) async {
    try {
      await _client.from('projects').delete().eq('id', id).eq('user_id', _uid);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/result.dart';
import '../domain/models.dart';
import 'mappers.dart';
import 'storage_paths.dart';

class ScreenRepository {
  ScreenRepository(this._client);
  final SupabaseClient _client;
  final _uuid = const Uuid();

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not authenticated');
    return id;
  }

  Future<List<AppScreen>> listScreens(String projectId) async {
    final rows = await _client
        .from('app_screens')
        .select()
        .eq('project_id', projectId)
        .order('sort_order');
    final screens = (rows as List)
        .cast<Map<String, dynamic>>()
        .map(mapAppScreen)
        .toList();
    if (screens.isEmpty) return screens;

    final assetIds = screens.map((s) => s.assetId).toList();
    final assets = await _client.from('assets').select().inFilter('id', assetIds);
    final byId = <String, AssetRecord>{
      for (final row in (assets as List).cast<Map<String, dynamic>>())
        row['id'] as String: mapAsset(row),
    };

    final result = <AppScreen>[];
    for (final screen in screens) {
      final asset = byId[screen.assetId];
      String? url;
      if (asset != null) {
        url = await _signedUrl(asset.storagePath);
      }
      result.add(
        AppScreen(
          id: screen.id,
          projectId: screen.projectId,
          assetId: screen.assetId,
          name: screen.name,
          sortOrder: screen.sortOrder,
          previewUrl: url,
          asset: asset,
        ),
      );
    }
    return result;
  }

  Future<Result<AppScreen>> uploadScreen({
    required String projectId,
    required File file,
    String? name,
  }) async {
    final assetId = _uuid.v4();
    final fileName = _safeName(p.basename(file.path));
    final mime = _mimeFor(fileName);
    final bytes = await file.readAsBytes();
    final size = await _decodeSize(bytes);
    final path = projectScreenshotPath(
      userId: _uid,
      projectId: projectId,
      assetId: assetId,
      fileName: fileName,
    );

    try {
      await _client.storage.from(storageBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: false),
          );

      await _client.from('assets').insert({
        'id': assetId,
        'user_id': _uid,
        'project_id': projectId,
        'type': 'app_screenshot',
        'storage_path': path,
        'file_name': fileName,
        'mime_type': mime,
        'file_size': bytes.length,
        'width': size.$1,
        'height': size.$2,
      });

      final existing = await _client
          .from('app_screens')
          .select('sort_order')
          .eq('project_id', projectId)
          .order('sort_order', ascending: false)
          .limit(1);
      final nextOrder = existing.isEmpty
          ? 0
          : ((existing.first['sort_order'] as num?)?.toInt() ?? 0) + 1;

      final row = await _client
          .from('app_screens')
          .insert({
            'project_id': projectId,
            'asset_id': assetId,
            'name': name ?? p.basenameWithoutExtension(fileName),
            'sort_order': nextOrder,
          })
          .select()
          .single();

      try {
        await _client.rpc('bump_usage_counter', params: {'p_field': 'screens_uploaded'});
      } catch (_) {}

      final mapped = mapAppScreen(Map<String, dynamic>.from(row));
      return Ok(
        AppScreen(
          id: mapped.id,
          projectId: mapped.projectId,
          assetId: mapped.assetId,
          name: mapped.name,
          sortOrder: mapped.sortOrder,
          previewUrl: await _signedUrl(path),
        ),
      );
    } catch (e) {
      try {
        await _client.from('assets').delete().eq('id', assetId);
        await _client.storage.from(storageBucket).remove([path]);
      } catch (_) {}
      return Err(e.toString());
    }
  }

  Future<Result<void>> renameScreen(String id, String name) async {
    try {
      await _client.from('app_screens').update({'name': name.trim()}).eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> reorderScreens(List<AppScreen> ordered) async {
    try {
      for (var i = 0; i < ordered.length; i++) {
        await _client
            .from('app_screens')
            .update({'sort_order': i})
            .eq('id', ordered[i].id);
      }
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> deleteScreen(AppScreen screen) async {
    try {
      await _client.from('app_screens').delete().eq('id', screen.id);
      if (screen.asset != null) {
        await _client.from('assets').delete().eq('id', screen.asset!.id);
        await _client.storage.from(storageBucket).remove([
          screen.asset!.storagePath,
        ]);
      }
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<String?> signedUrlForAssetId(String assetId) async {
    final row =
        await _client.from('assets').select().eq('id', assetId).maybeSingle();
    if (row == null) return null;
    return _signedUrl(row['storage_path'] as String);
  }

  Future<Map<String, String?>> signedUrlsForAssetIds(Iterable<String> ids) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return {};
    final rows = await _client.from('assets').select().inFilter('id', unique);
    final result = <String, String?>{};
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      result[row['id'] as String] = await _signedUrl(row['storage_path'] as String);
    }
    return result;
  }

  Future<String?> _signedUrl(String path) async {
    try {
      return await _client.storage.from(storageBucket).createSignedUrl(path, 3600);
    } catch (_) {
      return null;
    }
  }

  String _safeName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'screenshot.png' : cleaned;
  }

  String _mimeFor(String name) {
    final ext = p.extension(name).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/png';
    }
  }

  Future<(int?, int?)> _decodeSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return (frame.image.width, frame.image.height);
    } catch (_) {
      return (null, null);
    }
  }
}

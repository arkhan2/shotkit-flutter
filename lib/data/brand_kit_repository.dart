import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/hex.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../domain/models.dart';
import 'mappers.dart';
import 'storage_paths.dart';

class BrandKitRepository {
  BrandKitRepository(this._client);
  final SupabaseClient _client;
  final _uuid = const Uuid();

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not authenticated');
    return id;
  }

  Future<List<BrandKitWithColors>> listKits() async {
    final rows = await _client
        .from('brand_kits')
        .select()
        .eq('user_id', _uid)
        .order('updated_at', ascending: false);
    final kits = (rows as List).cast<Map<String, dynamic>>().map(mapBrandKit);
    final result = <BrandKitWithColors>[];
    for (final kit in kits) {
      result.add(await _hydrate(kit));
    }
    return result;
  }

  Future<BrandKitWithColors?> getKit(String id) async {
    final row = await _client
        .from('brand_kits')
        .select()
        .eq('id', id)
        .eq('user_id', _uid)
        .maybeSingle();
    if (row == null) return null;
    return _hydrate(mapBrandKit(Map<String, dynamic>.from(row)));
  }

  Future<Result<BrandKit>> createKit(String name) async {
    final error = validateBrandKitName(name);
    if (error != null) return Err(error);
    try {
      final row = await _client
          .from('brand_kits')
          .insert({'user_id': _uid, 'name': name.trim()})
          .select()
          .single();
      return Ok(mapBrandKit(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> renameKit(String id, String name) async {
    final error = validateBrandKitName(name);
    if (error != null) return Err(error);
    try {
      await _client
          .from('brand_kits')
          .update({'name': name.trim()})
          .eq('id', id)
          .eq('user_id', _uid);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> deleteKit(String id) async {
    try {
      await _client.from('brand_kits').delete().eq('id', id).eq('user_id', _uid);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<BrandColor>> addColor({
    required String brandKitId,
    required String name,
    required String hex,
  }) async {
    if (!isValidHex(hex)) return const Err('Use a #RRGGBB color.');
    try {
      final existing = await _client
          .from('brand_colors')
          .select('sort_order')
          .eq('brand_kit_id', brandKitId)
          .order('sort_order', ascending: false)
          .limit(1);
      final next = existing.isEmpty
          ? 0
          : ((existing.first['sort_order'] as num?)?.toInt() ?? 0) + 1;
      final row = await _client
          .from('brand_colors')
          .insert({
            'brand_kit_id': brandKitId,
            'name': name.trim().isEmpty ? 'Color' : name.trim(),
            'hex': normalizeHex(hex),
            'sort_order': next,
          })
          .select()
          .single();
      return Ok(mapBrandColor(Map<String, dynamic>.from(row)));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> updateColor(BrandColor color) async {
    if (!isValidHex(color.hex)) return const Err('Use a #RRGGBB color.');
    try {
      await _client.from('brand_colors').update({
        'name': color.name,
        'hex': normalizeHex(color.hex),
        'sort_order': color.sortOrder,
      }).eq('id', color.id);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> deleteColor(String id) async {
    try {
      await _client.from('brand_colors').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<void>> uploadLogo({
    required String brandKitId,
    required File file,
    required String variant,
  }) async {
    final assetId = _uuid.v4();
    final fileName = p.basename(file.path).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final bytes = await file.readAsBytes();
    final path = brandLogoPath(
      userId: _uid,
      brandKitId: brandKitId,
      assetId: assetId,
      fileName: fileName,
    );
    final mime = fileName.toLowerCase().endsWith('.svg')
        ? 'image/svg+xml'
        : fileName.toLowerCase().endsWith('.jpg') ||
                fileName.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : 'image/png';
    try {
      await _client.storage.from(storageBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: false),
          );
      final size = await _decodeSize(bytes);
      await _client.from('assets').insert({
        'id': assetId,
        'user_id': _uid,
        'brand_kit_id': brandKitId,
        'type': 'logo',
        'storage_path': path,
        'file_name': fileName,
        'mime_type': mime,
        'file_size': bytes.length,
        'width': size.$1,
        'height': size.$2,
      });
      final current = await getKit(brandKitId);
      final previousId = variant == 'dark'
          ? current?.kit.logoDarkAssetId
          : (current?.kit.logoLightAssetId ?? current?.kit.logoAssetId);
      final patch = variant == 'dark'
          ? {'logo_dark_asset_id': assetId}
          : {
              'logo_light_asset_id': assetId,
              'logo_asset_id': assetId,
            };
      await _client.from('brand_kits').update(patch).eq('id', brandKitId);
      if (previousId != null && previousId != assetId) {
        await _deleteAssetIfUnreferenced(previousId);
      }
      return const Ok(null);
    } catch (e) {
      try {
        await _client.from('assets').delete().eq('id', assetId);
        await _client.storage.from(storageBucket).remove([path]);
      } catch (_) {}
      return Err(e.toString());
    }
  }

  Future<Result<void>> removeLogo({
    required String brandKitId,
    required String variant,
  }) async {
    try {
      final current = await getKit(brandKitId);
      if (current == null) return const Err('Brand Kit not found.');
      final previousId = variant == 'dark'
          ? current.kit.logoDarkAssetId
          : (current.kit.logoLightAssetId ?? current.kit.logoAssetId);
      final patch = variant == 'dark'
          ? {'logo_dark_asset_id': null}
          : {
              'logo_light_asset_id': null,
              'logo_asset_id': null,
            };
      await _client
          .from('brand_kits')
          .update(patch)
          .eq('id', brandKitId)
          .eq('user_id', _uid);
      if (previousId != null) {
        await _deleteAssetIfUnreferenced(previousId);
      }
      return const Ok(null);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<BrandKitWithColors> _hydrate(BrandKit kit) async {
    final colorRows = await _client
        .from('brand_colors')
        .select()
        .eq('brand_kit_id', kit.id)
        .order('sort_order');
    final colors = (colorRows as List)
        .cast<Map<String, dynamic>>()
        .map(mapBrandColor)
        .toList();
    return BrandKitWithColors(
      kit: kit,
      colors: colors,
      logoUrl: await _url(kit.logoAssetId),
      logoLightUrl: await _url(kit.logoLightAssetId),
      logoDarkUrl: await _url(kit.logoDarkAssetId),
    );
  }

  Future<String?> _url(String? assetId) async {
    if (assetId == null) return null;
    final row =
        await _client.from('assets').select().eq('id', assetId).maybeSingle();
    if (row == null) return null;
    try {
      return await _client.storage
          .from(storageBucket)
          .createSignedUrl(row['storage_path'] as String, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteAssetIfUnreferenced(String assetId) async {
    final row =
        await _client.from('assets').select().eq('id', assetId).maybeSingle();
    if (row == null) return;
    final refs = await Future.wait([
      _countEq('app_screens', 'asset_id', assetId),
      _countEq('brand_kits', 'logo_asset_id', assetId),
      _countEq('brand_kits', 'logo_light_asset_id', assetId),
      _countEq('brand_kits', 'logo_dark_asset_id', assetId),
    ]);
    if (refs.any((count) => count > 0)) return;
    final path = row['storage_path'] as String?;
    if (path != null) {
      try {
        await _client.storage.from(storageBucket).remove([path]);
      } catch (_) {}
    }
    await _client.from('assets').delete().eq('id', assetId);
  }

  Future<int> _countEq(String table, String column, String value) async {
    final rows = await _client.from(table).select('id').eq(column, value);
    return (rows as List).length;
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

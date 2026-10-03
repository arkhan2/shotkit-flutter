import '../domain/document.dart';
import '../domain/models.dart';

DateTime _dt(Object? value) {
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

Project mapProject(Map<String, dynamic> row) {
  return Project(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    name: row['name'] as String,
    description: row['description'] as String?,
    brandKitId: row['brand_kit_id'] as String?,
    createdAt: _dt(row['created_at']),
    updatedAt: _dt(row['updated_at']),
  );
}

BrandKit mapBrandKit(Map<String, dynamic> row) {
  return BrandKit(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    name: row['name'] as String,
    logoAssetId: row['logo_asset_id'] as String?,
    logoLightAssetId:
        (row['logo_light_asset_id'] as String?) ?? row['logo_asset_id'] as String?,
    logoDarkAssetId: row['logo_dark_asset_id'] as String?,
    createdAt: _dt(row['created_at']),
    updatedAt: _dt(row['updated_at']),
  );
}

BrandColor mapBrandColor(Map<String, dynamic> row) {
  return BrandColor(
    id: row['id'] as String,
    brandKitId: row['brand_kit_id'] as String,
    name: row['name'] as String,
    hex: row['hex'] as String,
    sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
  );
}

AssetRecord mapAsset(Map<String, dynamic> row) {
  return AssetRecord(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    projectId: row['project_id'] as String?,
    brandKitId: row['brand_kit_id'] as String?,
    type: row['type'] as String,
    storagePath: row['storage_path'] as String,
    fileName: row['file_name'] as String,
    mimeType: row['mime_type'] as String,
    fileSize: (row['file_size'] as num?)?.toInt() ?? 0,
    width: (row['width'] as num?)?.toInt(),
    height: (row['height'] as num?)?.toInt(),
  );
}

AppScreen mapAppScreen(Map<String, dynamic> row) {
  return AppScreen(
    id: row['id'] as String,
    projectId: row['project_id'] as String,
    assetId: row['asset_id'] as String,
    name: row['name'] as String?,
    sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
  );
}

Design mapDesign(Map<String, dynamic> row, {int pageCount = 0}) {
  final document = row['document'];
  return Design(
    id: row['id'] as String,
    projectId: row['project_id'] as String,
    name: row['name'] as String,
    platform: row['platform'] as String,
    deviceType: row['device_type'] as String,
    width: (row['width'] as num).toInt(),
    height: (row['height'] as num).toInt(),
    document: DesignMetaDocument.fromJson(
      document is Map ? Map<String, dynamic>.from(document) : null,
    ),
    documentVersion: (row['document_version'] as num?)?.toInt() ?? 1,
    createdAt: _dt(row['created_at']),
    updatedAt: _dt(row['updated_at']),
    pageCount: pageCount,
  );
}

DesignPage mapDesignPage(Map<String, dynamic> row) {
  final document = row['document'];
  if (document is! Map) {
    throw StateError('Invalid DesignDocument JSON on design_pages.document');
  }
  return DesignPage(
    id: row['id'] as String,
    designId: row['design_id'] as String,
    sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    name: row['name'] as String?,
    document: DesignDocument.fromJson(Map<String, dynamic>.from(document)),
    documentVersion: (row['document_version'] as num?)?.toInt() ?? 1,
  );
}

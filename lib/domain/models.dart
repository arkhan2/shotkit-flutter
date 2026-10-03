import 'document.dart';

class Project {
  const Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.brandKitId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? brandKitId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ProjectListItem extends Project {
  const ProjectListItem({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    super.brandKitId,
    required super.createdAt,
    required super.updatedAt,
    required this.screenCount,
    this.brandKitName,
  });

  final int screenCount;
  final String? brandKitName;
}

class BrandColor {
  const BrandColor({
    required this.id,
    required this.brandKitId,
    required this.name,
    required this.hex,
    required this.sortOrder,
  });

  final String id;
  final String brandKitId;
  final String name;
  final String hex;
  final int sortOrder;
}

class BrandKit {
  const BrandKit({
    required this.id,
    required this.userId,
    required this.name,
    this.logoAssetId,
    this.logoLightAssetId,
    this.logoDarkAssetId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? logoAssetId;
  final String? logoLightAssetId;
  final String? logoDarkAssetId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class BrandKitWithColors {
  const BrandKitWithColors({
    required this.kit,
    required this.colors,
    this.logoUrl,
    this.logoLightUrl,
    this.logoDarkUrl,
  });

  final BrandKit kit;
  final List<BrandColor> colors;
  final String? logoUrl;
  final String? logoLightUrl;
  final String? logoDarkUrl;

  String? get resolvedLogoAssetId =>
      kit.logoLightAssetId ?? kit.logoAssetId ?? kit.logoDarkAssetId;
}

class AssetRecord {
  const AssetRecord({
    required this.id,
    required this.userId,
    this.projectId,
    this.brandKitId,
    required this.type,
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
  });

  final String id;
  final String userId;
  final String? projectId;
  final String? brandKitId;
  final String type;
  final String storagePath;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;
}

class AppScreen {
  const AppScreen({
    required this.id,
    required this.projectId,
    required this.assetId,
    this.name,
    required this.sortOrder,
    this.previewUrl,
    this.asset,
  });

  final String id;
  final String projectId;
  final String assetId;
  final String? name;
  final int sortOrder;
  final String? previewUrl;
  final AssetRecord? asset;
}

class Design {
  const Design({
    required this.id,
    required this.projectId,
    required this.name,
    required this.platform,
    required this.deviceType,
    required this.width,
    required this.height,
    required this.document,
    required this.documentVersion,
    required this.createdAt,
    required this.updatedAt,
    this.pageCount = 0,
  });

  final String id;
  final String projectId;
  final String name;
  final String platform;
  final String deviceType;
  final int width;
  final int height;
  final DesignMetaDocument document;
  final int documentVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
}

class DesignPage {
  const DesignPage({
    required this.id,
    required this.designId,
    required this.sortOrder,
    this.name,
    required this.document,
    required this.documentVersion,
  });

  final String id;
  final String designId;
  final int sortOrder;
  final String? name;
  final DesignDocument document;
  final int documentVersion;
}

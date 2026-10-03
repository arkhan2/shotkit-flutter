const storageBucket = 'assets';

String projectScreenshotPath({
  required String userId,
  required String projectId,
  required String assetId,
  required String fileName,
}) {
  return 'users/$userId/projects/$projectId/screenshots/$assetId/$fileName';
}

String brandLogoPath({
  required String userId,
  required String brandKitId,
  required String assetId,
  required String fileName,
}) {
  return 'users/$userId/brand-kits/$brandKitId/logos/$assetId/$fileName';
}

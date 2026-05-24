import '../../../../../core/config/app_config.dart';

String? buildSupplierRfqPublicImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return null;

  final value = imageUrl.trim().replaceAll('\\', '/');
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return Uri.encodeFull(value);
  }

  // The backend stores RFQ images under /uploadsPublic/rfqs/... and serves
  // them from the wholesale backend root, not from /api.
  final backendRoot = AppConfig.overrideRootUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final cleanPath = value.startsWith('/') ? value : '/$value';
  final normalizedPath = cleanPath.startsWith('/api/uploadsPublic/')
      ? cleanPath.replaceFirst('/api', '')
      : cleanPath;

  return Uri.encodeFull('$backendRoot$normalizedPath');
}

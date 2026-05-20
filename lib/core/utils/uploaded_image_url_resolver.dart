import '../config/app_config.dart';

class UploadedImageUrlResolver {
  const UploadedImageUrlResolver._();

  static String? resolve(String? imageUrl) {
    if (imageUrl == null) return null;

    final value = imageUrl.trim();
    if (value.isEmpty) return null;

    // Backend-uploaded images should always be displayed from the current
    // wholesale backend root. This also fixes old saved absolute URLs that
    // contain an outdated laptop IP/port.
    final backendPath = toBackendPath(value);
    if (backendPath != null) {
      return '${_wholesaleRootUrl()}$backendPath';
    }

    // External images are already complete URLs and should not be changed.
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // Local device paths cannot be loaded on another phone.
    // If this appears, supplier upload did not store a backend URL.
    if (value.startsWith('/storage/') ||
        value.startsWith('file://') ||
        value.contains(':\\')) {
      return null;
    }

    // Fallback: treat it as a backend-relative file path.
    return '${_wholesaleRootUrl()}/${value.replaceFirst(RegExp(r'^/+'), '')}';
  }

  static String normalizeForBackend(String? imageUrl) {
    if (imageUrl == null) return '';

    final value = imageUrl.trim();
    if (value.isEmpty) return '';

    return toBackendPath(value) ?? value;
  }

  static String? toBackendPath(String? imageUrl) {
    if (imageUrl == null) return null;

    final value = imageUrl.trim();
    if (value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    final path = uri?.hasScheme == true ? uri!.path : value;
    final cleanPath = path.trim();

    if (cleanPath.startsWith('/uploadsPublic/') ||
        cleanPath.startsWith('/uploads/')) {
      return cleanPath;
    }

    if (cleanPath.startsWith('uploadsPublic/') ||
        cleanPath.startsWith('uploads/')) {
      return '/$cleanPath';
    }

    return null;
  }

  static String _wholesaleRootUrl() {
    final clean = AppConfig.overrideRootUrl.trim().replaceAll(
      RegExp(r'/+$'),
      '',
    );

    if (clean.endsWith('/api')) {
      return clean.substring(0, clean.length - 4);
    }

    return clean;
  }
}

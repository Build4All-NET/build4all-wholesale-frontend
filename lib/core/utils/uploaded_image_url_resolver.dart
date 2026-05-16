import '../config/app_config.dart';

class UploadedImageUrlResolver {
  const UploadedImageUrlResolver._();

  static String? resolve(String? imageUrl) {
    if (imageUrl == null) return null;

    final value = imageUrl.trim();
    if (value.isEmpty) return null;

    // Already a full URL.
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // Backend returns this for uploaded product images.
    // Example:
    // /uploadsPublic/products/product_xxx.jpg
    if (value.startsWith('/uploadsPublic/') || value.startsWith('/uploads/')) {
      return '${_wholesaleRootUrl()}$value';
    }

    // If backend returns without the first slash:
    // uploadsPublic/products/product_xxx.jpg
    if (value.startsWith('uploadsPublic/') || value.startsWith('uploads/')) {
      return '${_wholesaleRootUrl()}/$value';
    }

    // Local device paths cannot be loaded on another phone.
    // If this appears, supplier upload did not store a backend URL.
    if (value.startsWith('/storage/') ||
        value.startsWith('file://') ||
        value.contains(':\\')) {
      return null;
    }

    // Fallback: treat it as a backend-relative file path.
    return '${_wholesaleRootUrl()}/$value';
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

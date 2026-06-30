import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Normalizes images returned by `image_picker` before they are uploaded.
///
/// iPhone photos are wide-gamut (Display P3) and Live Photos are HEIC. Uploaded
/// as-is they render with a heavy green/oversaturated cast. Running the picked
/// file through the platform's native image pipeline here re-encodes it to a
/// plain **sRGB** JPEG (or PNG), which decodes HEIC and converts the color
/// space correctly on-device — so the bytes that reach the backend are already
/// correct on every platform.
///
/// Conversion is best-effort: if anything fails, the original path is returned
/// so picking an image never breaks.
class PickedImageNormalizer {
  const PickedImageNormalizer._();

  /// Returns the path to an sRGB-normalized copy of [sourcePath], or
  /// [sourcePath] unchanged if conversion is not possible.
  static Future<String> toSrgb(String sourcePath) async {
    try {
      final lower = sourcePath.toLowerCase();
      final isPng = lower.endsWith('.png');

      final dotIndex = sourcePath.lastIndexOf('.');
      final base = dotIndex > 0 ? sourcePath.substring(0, dotIndex) : sourcePath;
      final targetPath = '${base}_srgb${isPng ? '.png' : '.jpg'}';

      if (targetPath == sourcePath) return sourcePath;

      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        // PNG keeps transparency (e.g. logos); everything else becomes JPEG.
        format: isPng ? CompressFormat.png : CompressFormat.jpeg,
        quality: 92,
        keepExif: false,
      );

      return result?.path ?? sourcePath;
    } catch (_) {
      return sourcePath;
    }
  }
}

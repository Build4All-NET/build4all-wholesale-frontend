import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders a just-picked file as an image on every platform.
///
/// `Image.file` throws in a browser because `dart:io.File` is not supported
/// there, while a picked file's path on web is a `blob:` URL that
/// [Image.network] loads directly. Native platforms keep using [Image.file].
class PickedImage extends StatelessWidget {
  /// Path of the picked file — a filesystem path on native, a `blob:` URL on
  /// web.
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const PickedImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: errorBuilder,
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: errorBuilder,
    );
  }
}

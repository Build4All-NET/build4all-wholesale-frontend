import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;

// Helpers for a file the user just picked, which this app carries around as a
// path string.
//
// In a browser that path is a `blob:` URL and not a filesystem path, so
// everything routed through `dart:io.File` — checking existence, reading,
// `MultipartFile.fromFile` — fails there. These keep a picked file usable on
// every platform.

/// Extensions the backends accept for an uploaded image.
const Set<String> _imageExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

/// The file name at the end of [path], for either path separator.
String pickedFileName(String path) => path.split(RegExp(r'[\\/]')).last;

/// Whether [path] still points at a picked file the app can read.
///
/// Native builds ask the filesystem. The browser has none, and it only ever
/// hands out a blob URL for a file that was actually picked, so there a
/// non-empty path is the whole check.
bool pickedFileExists(String path) {
  if (path.trim().isEmpty) return false;
  if (kIsWeb) return true;

  return File(path).existsSync();
}

/// Builds the multipart part for a picked file on every platform.
///
/// `MultipartFile.fromFile` needs a real filesystem path, which the browser
/// never provides. [XFile.readAsBytes] reads through the blob URL there and off
/// the filesystem everywhere else, so the bytes are read up front and the file
/// name is carried across explicitly.
Future<MultipartFile> multipartFromPickedPath(
  String path, {
  String? filename,
}) async {
  final bytes = await XFile(path).readAsBytes();

  return MultipartFile.fromBytes(
    bytes,
    filename: _uploadFileName(filename ?? pickedFileName(path), bytes),
  );
}

/// Returns a file name the backend will accept for [bytes].
///
/// A blob URL ends in an opaque id with no extension, and the backends decide
/// what they will store from the extension alone — so when the name carries no
/// usable one, the image type is read from the bytes instead of guessed.
String _uploadFileName(String name, Uint8List bytes) {
  final trimmed = name.trim();
  final base = trimmed.isEmpty ? 'upload' : trimmed;

  final dot = base.lastIndexOf('.');
  final extension = dot == -1 ? '' : base.substring(dot + 1).toLowerCase();

  if (_imageExtensions.contains(extension)) return base;

  final sniffed = _imageExtensionFromBytes(bytes);
  if (sniffed == null) return base;

  return '${dot == -1 ? base : base.substring(0, dot)}.$sniffed';
}

/// The image type [bytes] start with, or null when it is not one this app
/// uploads.
String? _imageExtensionFromBytes(Uint8List bytes) {
  bool startsWith(List<int> signature, {int offset = 0}) {
    if (bytes.length < offset + signature.length) return false;

    for (var i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature[i]) return false;
    }

    return true;
  }

  if (startsWith([0xFF, 0xD8, 0xFF])) return 'jpg';
  if (startsWith([0x89, 0x50, 0x4E, 0x47])) return 'png';
  if (startsWith([0x52, 0x49, 0x46, 0x46]) &&
      startsWith([0x57, 0x45, 0x42, 0x50], offset: 8)) {
    return 'webp';
  }
  if (startsWith([0x47, 0x49, 0x46, 0x38])) return 'gif';

  return null;
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeStorage {
  static const _storage = FlutterSecureStorage();
  static const _seedColorKey = 'theme_seed_color';
  static const _brightnessKey = 'theme_brightness';

  Future<void> saveTheme({
    required Color seedColor,
    required Brightness brightness,
  }) async {
    await _storage.write(
      key: _seedColorKey,
      value: seedColor.toARGB32().toRadixString(16),
    );

    await _storage.write(
      key: _brightnessKey,
      value: brightness.name,
    );
  }

  Future<Color?> getSeedColor() async {
    final value = await _storage.read(key: _seedColorKey);
    if (value == null) return null;

    final intValue = int.tryParse(value, radix: 16);
    if (intValue == null) return null;

    return Color(intValue);
  }

  Future<Brightness?> getBrightness() async {
    final value = await _storage.read(key: _brightnessKey);
    if (value == null) return null;

    if (value == 'dark') return Brightness.dark;
    return Brightness.light;
  }

  Future<void> clearTheme() async {
    await _storage.delete(key: _seedColorKey);
    await _storage.delete(key: _brightnessKey);
  }
}

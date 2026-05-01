import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BrandingStorage {
  static const _storage = FlutterSecureStorage();

  static const _appNameKey = 'runtime_app_name';
  static const _logoUrlKey = 'runtime_logo_url';

  Future<void> saveBranding({
    required String appName,
    required String logoUrl,
  }) async {
    await _storage.write(key: _appNameKey, value: appName);
    await _storage.write(key: _logoUrlKey, value: logoUrl);
  }

  Future<String?> getAppName() async => _storage.read(key: _appNameKey);

  Future<String?> getLogoUrl() async => _storage.read(key: _logoUrlKey);

  Future<void> clearBranding() async {
    await _storage.delete(key: _appNameKey);
    await _storage.delete(key: _logoUrlKey);
  }
}
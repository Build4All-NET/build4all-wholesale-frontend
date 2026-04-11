import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleStorage {
  static const _storage = FlutterSecureStorage();
  static const _localeKey = 'selected_locale';

  Future<void> saveLocale(String languageCode) async {
    await _storage.write(key: _localeKey, value: languageCode);
  }

  Future<String?> getLocale() async {
    return await _storage.read(key: _localeKey);
  }

  Future<void> clearLocale() async {
    await _storage.delete(key: _localeKey);
  }
}

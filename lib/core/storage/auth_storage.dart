import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'role';
  static const _profileCompletedKey = 'profile_completed';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String role,
    required bool profileCompleted,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(
      key: _profileCompletedKey,
      value: profileCompleted.toString(),
    );
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<int?> getUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  Future<bool?> getProfileCompleted() async {
    final value = await _storage.read(key: _profileCompletedKey);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'build4all_access_token';
  static const _build4allUserIdKey = 'build4all_user_id';
  static const _ownerProjectLinkIdKey = 'owner_project_link_id';
  static const _roleKey = 'role';
  static const _profileCompletedKey = 'profile_completed';
  static const _emailKey = 'email';
  static const _fullNameKey = 'full_name';

  Future<void> saveSession({
    required String token,
    required int build4allUserId,
    required int ownerProjectLinkId,
    required String role,
    required bool profileCompleted,
    required String email,
    required String fullName,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _build4allUserIdKey,
      value: build4allUserId.toString(),
    );
    await _storage.write(
      key: _ownerProjectLinkIdKey,
      value: ownerProjectLinkId.toString(),
    );
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(
      key: _profileCompletedKey,
      value: profileCompleted.toString(),
    );
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _fullNameKey, value: fullName);
  }

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<int?> getBuild4allUserId() async {
    final value = await _storage.read(key: _build4allUserIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<int?> getOwnerProjectLinkId() async {
    final value = await _storage.read(key: _ownerProjectLinkIdKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<String?> getRole() async => _storage.read(key: _roleKey);

  Future<bool?> getProfileCompleted() async {
    final value = await _storage.read(key: _profileCompletedKey);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  Future<String?> getEmail() async => _storage.read(key: _emailKey);

  Future<String?> getFullName() async => _storage.read(key: _fullNameKey);

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}

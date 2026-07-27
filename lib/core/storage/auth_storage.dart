import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _hasLaunchedBeforeKey = 'has_launched_before';
  static const _tokenKey = 'build4all_access_token';
  static const _refreshTokenKey = 'build4all_refresh_token';
  static const _build4allUserIdKey = 'build4all_user_id';
  static const _ownerProjectLinkIdKey = 'owner_project_link_id';
  static const _roleKey = 'role';
  static const _profileCompletedKey = 'profile_completed';
  static const _emailKey = 'email';
  static const _fullNameKey = 'full_name';

  Future<void> saveSession({
    required String token,
    required String refreshToken,
    required int build4allUserId,
    required int ownerProjectLinkId,
    required String role,
    required bool profileCompleted,
    required String email,
    required String fullName,
  }) async {
    await _storage.write(key: _tokenKey, value: _cleanToken(token));
    await _storage.write(key: _refreshTokenKey, value: refreshToken.trim());
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

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null ? _cleanToken(token) : null;
  }

  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    final trimmed = token?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Replaces only the access + refresh tokens after a successful refresh,
  /// leaving the rest of the session (user id, role, profile flags) intact.
  Future<void> updateTokens({
    required String token,
    required String refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: _cleanToken(token));
    await _storage.write(key: _refreshTokenKey, value: refreshToken.trim());
  }

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

  /// iOS Keychain entries (unlike the rest of the app's storage) survive an
  /// uninstall, so a fresh install can silently inherit a session — and
  /// `profile_completed` flag — from a previous install, skipping straight
  /// past `/login`. `has_launched_before` lives in SharedPreferences, which
  /// iOS *does* wipe on uninstall, so it reliably flags a genuinely first
  /// launch of this install and lets us clear any leftover Keychain session
  /// before the router ever looks at it.
  Future<void> clearStaleSessionOnFreshInstall() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_hasLaunchedBeforeKey) == true) return;

    await clearSession();
    await prefs.setBool(_hasLaunchedBeforeKey, true);
  }

  String _cleanToken(String token) {
    final trimmed = token.trim();

    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }

    return trimmed;
  }
}

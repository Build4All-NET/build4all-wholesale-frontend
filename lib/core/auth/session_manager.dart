import 'package:flutter/foundation.dart';

import '../storage/auth_storage.dart';
import '../../features/auth/data/services/auth_service.dart';

/// Lifecycle of the user's session, as seen by the router.
enum AuthStatus {
  /// Cold start: we haven't decided yet (still validating stored credentials).
  unknown,

  /// A valid session is restored / active.
  authenticated,

  /// No session — the user must log in.
  unauthenticated,
}

/// Single source of truth for authentication across both sides of the app
/// (retailer/user and supplier/admin).
///
/// The router listens to this (via `refreshListenable`) so navigation reacts
/// to session changes automatically: restoring a saved session on launch,
/// landing on the right dashboard after login, and bouncing back to `/login`
/// the moment the session ends — whether the user tapped logout or the refresh
/// token was rejected mid-session.
class SessionManager extends ChangeNotifier {
  SessionManager({
    required this.authStorage,
    required this.authService,
  });

  final AuthStorage authStorage;
  final AuthService authService;

  AuthStatus _status = AuthStatus.unknown;
  String _role = '';
  bool _profileCompleted = false;

  AuthStatus get status => _status;
  String get role => _role;
  bool get profileCompleted => _profileCompleted;

  bool get isSupplier => _role == 'SUPPLIER';
  bool get isRetailer => _role == 'RETAILER';

  /// Where an authenticated user belongs. Falls back to `/login` for an unknown
  /// role (corrupt or pre-existing session without a role).
  String get homeLocation {
    if (_status != AuthStatus.authenticated) return '/login';

    if (isSupplier) {
      return _profileCompleted
          ? '/supplier-dashboard'
          : '/complete-supplier-profile';
    }

    if (isRetailer) {
      return _profileCompleted
          ? '/retailer-dashboard'
          : '/complete-retailer-profile';
    }

    return '/login';
  }

  /// Restores and validates a stored session. Runs once on cold start.
  ///
  /// Hitting `/auth/me` here exercises the access token: the refresh
  /// interceptor transparently rotates an expired one, and clears the session
  /// if the refresh token is dead too (so the token is gone when we re-check).
  /// A transient/offline failure keeps the stored session optimistically rather
  /// than logging the user out for being offline.
  Future<void> bootstrap() async {
    final token = await authStorage.getToken();
    if (token == null || token.trim().isEmpty) {
      _setUnauthenticated();
      return;
    }

    _role = (await authStorage.getRole())?.toUpperCase().trim() ?? '';
    _profileCompleted = await authStorage.getProfileCompleted() ?? false;

    try {
      final me = await authService.getWholesaleMe();
      _profileCompleted = me.profileCompleted;
    } catch (_) {
      final stillLoggedIn = await authStorage.getToken();
      if (stillLoggedIn == null || stillLoggedIn.trim().isEmpty) {
        _setUnauthenticated();
        return;
      }
      // Transient error but the session is still valid — keep it.
    }

    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Marks the session active after a successful login.
  void onLogin({
    required String role,
    required bool profileCompleted,
  }) {
    _role = role.toUpperCase().trim();
    _profileCompleted = profileCompleted;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Keeps the session in sync once the user finishes completing their profile.
  void markProfileCompleted() {
    if (_profileCompleted) return;
    _profileCompleted = true;
    notifyListeners();
  }

  /// User-initiated logout: clears stored credentials and flips to logged out.
  Future<void> signOut() async {
    await authStorage.clearSession();
    _setUnauthenticated();
  }

  /// Called by the network layer when the refresh token is rejected and the
  /// stored session has already been cleared. Drives the global redirect to
  /// `/login` without each screen having to handle 401s itself.
  void onSessionExpired() {
    _setUnauthenticated();
  }

  void _setUnauthenticated() {
    _role = '';
    _profileCompleted = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

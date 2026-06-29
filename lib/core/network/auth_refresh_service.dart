import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

/// Raised when the refresh token is missing or has been rejected by the
/// backend. The caller should treat this as "session is over" and log out.
class RefreshTokenExpiredException implements Exception {
  final String message;

  const RefreshTokenExpiredException([
    this.message = 'Session expired. Please log in again.',
  ]);

  @override
  String toString() => message;
}

/// Rotates the build4all access token using the stored refresh token.
///
/// The refresh endpoint always lives on the central build4all backend
/// (`/api/auth/refresh`), even when the request that triggered the refresh
/// was sent to the wholesale project backend. Both the supplier (admin) and
/// retailer (user) sides share a single session, so a single stored refresh
/// token covers both.
///
/// Uses its own plain [Dio] so the refresh call never passes back through the
/// auth/refresh interceptors (no recursion), and de-duplicates concurrent
/// refreshes behind a single in-flight [Completer] so several simultaneous
/// 401s only rotate the token once.
class AuthRefreshService {
  AuthRefreshService(
    this.authStorage, {
    required String centralBaseUrl,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: centralBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final AuthStorage authStorage;
  final Dio _dio;

  Completer<String>? _inFlight;

  /// Returns a fresh access token, rotating the refresh token in storage.
  ///
  /// Concurrent callers share the same in-flight refresh. Throws a
  /// [RefreshTokenExpiredException] when the session can no longer be
  /// recovered, or rethrows transient [DioException]s (network) so the caller
  /// can keep the session and surface the original error instead.
  Future<String> refresh() {
    final existing = _inFlight;
    if (existing != null) return existing.future;

    final completer = Completer<String>();
    _inFlight = completer;

    _performRefresh().then(
      completer.complete,
      onError: (Object error, StackTrace stackTrace) {
        completer.completeError(error, stackTrace);
      },
    ).whenComplete(() {
      _inFlight = null;
    });

    return completer.future;
  }

  Future<String> _performRefresh() async {
    final refreshToken = (await authStorage.getRefreshToken())?.trim() ?? '';

    if (refreshToken.isEmpty) {
      throw const RefreshTokenExpiredException('No refresh token stored.');
    }

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      final newToken = (data['token'] ?? '').toString().trim();
      final newRefresh = (data['refreshToken'] ?? '').toString().trim();

      if (newToken.isEmpty || newRefresh.isEmpty) {
        throw const RefreshTokenExpiredException('Invalid refresh response.');
      }

      await authStorage.updateTokens(
        token: newToken,
        refreshToken: newRefresh,
      );

      return newToken;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;

      // A rejected refresh token is unrecoverable -> force re-login.
      if (status == 400 || status == 401 || status == 403) {
        throw const RefreshTokenExpiredException();
      }

      // Network / server hiccup: keep the session and bubble up so the
      // original request fails normally instead of logging the user out.
      rethrow;
    }
  }
}

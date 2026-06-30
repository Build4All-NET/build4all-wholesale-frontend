import 'package:dio/dio.dart';

import '../../storage/auth_storage.dart';
import '../auth_refresh_service.dart';

/// Catches expired-token responses on authenticated requests, rotates the
/// access token via [AuthRefreshService], then transparently replays the
/// original request with the new token.
///
/// Both `401 Unauthorized` and `403 Forbidden` are treated as token-expiry
/// triggers: the backend's JWT filter clears the security context when a token
/// is expired and lets the request continue unauthenticated, which Spring
/// Security answers with `403` (not `401`). Refreshing is only attempted when
/// the failed request actually carried a token, so a genuine permission denial
/// surfaces after a single retry rather than looping.
///
/// Works the same for both sides of the app (supplier/admin and retailer/user)
/// because they share a single session and the central refresh endpoint
/// rotates whichever subject the stored refresh token belongs to.
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required this.dio,
    required this.authStorage,
    required this.refreshService,
    this.onSessionExpired,
  });

  /// The client whose requests this interceptor guards. Used to replay the
  /// original request after a successful refresh.
  final Dio dio;
  final AuthStorage authStorage;
  final AuthRefreshService refreshService;

  /// Invoked once the session has been cleared because the refresh token was
  /// rejected. Lets the app redirect to login globally.
  final void Function()? onSessionExpired;

  /// Auth endpoints must never trigger a refresh-and-retry: a 401 here means
  /// the credentials/refresh token themselves were rejected.
  bool _isAuthCall(RequestOptions options) {
    final path = options.path;

    return path.contains('/auth/refresh') ||
        path.contains('/auth/admin/login') ||
        path.contains('/auth/user/login') ||
        path.contains('/auth/send-verification') ||
        path.contains('/auth/verify-email-code') ||
        path.contains('/auth/complete-profile');
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode ?? 0;
    final request = err.requestOptions;

    final alreadyRetried = request.extra['__retried'] == true;

    // The backend returns 403 (not 401) for an expired/invalid token, so both
    // are treated as auth failures.
    final isAuthFailure = status == 401 || status == 403;

    // Only refresh when the request actually carried a token; a 401/403 on an
    // anonymous request is a real authorization error, not an expiry.
    final sentToken = (request.headers['Authorization'] ?? '')
        .toString()
        .trim()
        .isNotEmpty;

    if (!isAuthFailure ||
        !sentToken ||
        _isAuthCall(request) ||
        alreadyRetried) {
      return handler.next(err);
    }

    try {
      final newToken = await refreshService.refresh();

      request.extra['__retried'] = true;
      request.headers['Authorization'] = 'Bearer $newToken';

      // A FormData body is single-use (its stream was already consumed on the
      // first attempt), so it must be cloned before the request can be replayed.
      if (request.data is FormData) {
        request.data = (request.data as FormData).clone();
      }

      final response = await dio.fetch(request);
      return handler.resolve(response);
    } on RefreshTokenExpiredException {
      // Refresh token gone or rejected -> the session is over.
      await authStorage.clearSession();
      onSessionExpired?.call();
      return handler.next(err);
    } catch (_) {
      // Transient refresh failure (e.g. network). Keep the session and let the
      // original error surface so the caller can retry later.
      return handler.next(err);
    }
  }
}

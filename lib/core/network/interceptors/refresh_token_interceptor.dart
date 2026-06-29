import 'package:dio/dio.dart';

import '../../storage/auth_storage.dart';
import '../auth_refresh_service.dart';

/// Catches `401 Unauthorized` responses on authenticated requests, rotates the
/// access token via [AuthRefreshService], then transparently replays the
/// original request with the new token.
///
/// Works the same for both sides of the app (supplier/admin and retailer/user)
/// because they share a single session and the central refresh endpoint
/// rotates whichever subject the stored refresh token belongs to.
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required this.dio,
    required this.authStorage,
    required this.refreshService,
  });

  /// The client whose requests this interceptor guards. Used to replay the
  /// original request after a successful refresh.
  final Dio dio;
  final AuthStorage authStorage;
  final AuthRefreshService refreshService;

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

    if (status != 401 || _isAuthCall(request) || alreadyRetried) {
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
      return handler.next(err);
    } catch (_) {
      // Transient refresh failure (e.g. network). Keep the session and let the
      // original 401 surface so the caller can retry later.
      return handler.next(err);
    }
  }
}

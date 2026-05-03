import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

class ApiClient {
  final Dio dio;
  final AuthStorage authStorage;

  ApiClient(this.authStorage, {required String baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          // These endpoints are public and should not require a token.
          final isPublicCentralAuth =
              path == '/auth/admin/login/front' ||
              path == '/auth/user/login' ||
              path == '/auth/send-verification' ||
              path == '/auth/verify-email-code' ||
              path == '/auth/complete-profile' ||
              path.startsWith('/users/reset-password') ||
              path.startsWith('/users/verify-reset-code') ||
              path.startsWith('/users/update-password');

          if (!isPublicCentralAuth) {
            final rawToken = await authStorage.getToken();
            final token = _cleanToken(rawToken);

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
      ),
    );
  }

  /// Prevents sending "Bearer Bearer token" if token was already saved with Bearer.
  String? _cleanToken(String? token) {
    if (token == null) return null;

    final trimmed = token.trim();

    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }

    return trimmed;
  }
}

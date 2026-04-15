import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

class ApiClient {
  final Dio dio;
  final AuthStorage authStorage;

  ApiClient(
    this.authStorage, {
    required String baseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          final isPublicAuthEndpoint =
              path == '/auth/login' ||
              path == '/auth/signup/retailer' ||
              path == '/auth/forgot-password' ||
              path == '/auth/reset-password' ||
              path == '/auth/build4all/supplier-sync' ||
              path == '/auth/admin/login/front';

          if (!isPublicAuthEndpoint) {
            final token = await authStorage.getToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            options.headers.remove('Authorization');
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}

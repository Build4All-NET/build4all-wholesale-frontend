import 'dart:io';

import 'package:dio/dio.dart';

import '../storage/auth_storage.dart';

class ApiClient {
  final Dio dio;
  final AuthStorage authStorage;

  ApiClient(this.authStorage, {required String baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          // Shorter connect/receive timeouts so a stale socket left over from a
          // Wi-Fi <-> mobile-data switch fails fast and is retried, instead of
          // hanging for a full minute. Uploads keep a generous send timeout.
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    // Recovers automatically from transient network failures (the classic
    // Wi-Fi -> mobile-data handoff that kills in-flight connections).
    dio.interceptors.add(_NetworkRetryInterceptor(dio));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          final isPublicCentralAuth =
              path == '/auth/admin/login/front' ||
              path == '/auth/user/login' ||
              path == '/auth/send-verification' ||
              path == '/auth/verify-email-code' ||
              path == '/auth/complete-profile' ||
              path.startsWith('/currencies') ||
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

          print(
            'API REQUEST: ${options.method} ${options.baseUrl}${options.path}',
          );
          print('API HEADERS: ${_safeHeaders(options.headers)}');
          print('API QUERY: ${options.queryParameters}');
          print('API BODY SAFE: ${_safeData(options.data)}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'API RESPONSE: ${response.requestOptions.method} '
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          print('STATUS CODE: ${response.statusCode}');
          print('RESPONSE DATA: ${response.data}');

          handler.next(response);
        },
        onError: (error, handler) {
          print(
            'API ERROR: ${error.requestOptions.method} '
            '${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          print('ERROR TYPE: ${error.type}');
          print('ERROR MESSAGE: ${error.message}');
          print('ERROR STATUS CODE: ${error.response?.statusCode}');
          print('ERROR RESPONSE DATA: ${error.response?.data}');

          handler.next(error);
        },
      ),
    );
  }

  String? _cleanToken(String? token) {
    if (token == null) return null;

    final trimmed = token.trim();

    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }

    return trimmed;
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final safe = Map<String, dynamic>.from(headers);

    if (safe.containsKey('Authorization')) {
      safe['Authorization'] = 'Bearer ***';
    }

    if (safe.containsKey('authorization')) {
      safe['authorization'] = 'Bearer ***';
    }

    return safe;
  }

  Object? _safeData(Object? data) {
    if (data == null) return null;

    if (data is FormData) {
      final fields = <String, dynamic>{};

      for (final field in data.fields) {
        fields[field.key] = _maskIfSensitive(field.key, field.value);
      }

      if (data.files.isNotEmpty) {
        fields['files'] = data.files
            .map((file) => {
                  'key': file.key,
                  'filename': file.value.filename,
                })
            .toList();
      }

      return fields;
    }

    if (data is Map) {
      return _safeMap(data);
    }

    if (data is List) {
      return data.map((item) {
        if (item is Map) return _safeMap(item);
        return item;
      }).toList();
    }

    return data;
  }

  Map<String, dynamic> _safeMap(Map data) {
    final safe = <String, dynamic>{};

    data.forEach((key, value) {
      final keyText = key.toString();

      if (value is Map) {
        safe[keyText] = _safeMap(value);
      } else if (value is List) {
        safe[keyText] = value.map((item) {
          if (item is Map) return _safeMap(item);
          return item;
        }).toList();
      } else {
        safe[keyText] = _maskIfSensitive(keyText, value);
      }
    });

    return safe;
  }

  Object? _maskIfSensitive(String key, Object? value) {
    final lowerKey = key.toLowerCase();

    if (lowerKey.contains('password') ||
        lowerKey.contains('token') ||
        lowerKey.contains('authorization')) {
      return '***';
    }

    return value;
  }
}

/// Retries requests that fail because of a transient connectivity drop.
///
/// When the device switches between Wi-Fi and mobile data, the previous
/// network's sockets die. A request issued around that moment fails (or hangs
/// until timeout) on the dead connection; retrying establishes a fresh
/// connection on the new network and succeeds, so the user never sees the
/// error.
class _NetworkRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  _NetworkRetryInterceptor(this.dio, {this.maxRetries = 2});

  bool _isRetriable(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        // Request never completed reaching the server -> safe to retry.
        return true;
      case DioExceptionType.receiveTimeout:
        // The server may have already processed a write request, so only retry
        // idempotent reads.
        final method = error.requestOptions.method.toUpperCase();
        return method == 'GET' || method == 'HEAD';
      case DioExceptionType.unknown:
        return error.error is SocketException;
      default:
        return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= maxRetries || !_isRetriable(err)) {
      return handler.next(err);
    }

    final nextAttempt = attempt + 1;

    // Small backoff so the new network interface has time to come up.
    await Future.delayed(Duration(milliseconds: 400 * nextAttempt));

    try {
      final response = await dio.fetch(
        options.copyWith(
          extra: {...options.extra, 'retry_attempt': nextAttempt},
        ),
      );
      return handler.resolve(response);
    } on DioException catch (error) {
      return handler.next(error);
    }
  }
}
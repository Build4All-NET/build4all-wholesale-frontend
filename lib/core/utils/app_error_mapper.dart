import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../exceptions/app_exception.dart';

class AppErrorMapper {
  static String toMessage(Object? error) {
    try {
      if (error == null) {
        return 'Something went wrong. Please try again.';
      }

      if (error is String) {
        return _sanitize(error);
      }

      if (error is AppException) {
        final original = error.original;

        if (original != null && original is! AppException) {
          return toMessage(original);
        }

        final mappedCode = _mapBackendCode(error.code);
        if (mappedCode != null) return mappedCode;

        if (error.message.trim().isNotEmpty) {
          return _sanitize(error.message);
        }
      }

      if (error is DioException) {
        return _dioToMessage(error);
      }

      if (error is SocketException) {
        return 'Connection error. Please check your internet connection.';
      }

      if (error is FormatException) {
        return 'Invalid server response. Please try again.';
      }

      if (error is ArgumentError) {
        return 'Invalid input. Please check your data.';
      }

      if (error is TypeError) {
        return 'Something went wrong. Please try again.';
      }

      return _sanitize(error.toString());
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  static String _dioToMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Please check the server address or network.';

      case DioExceptionType.cancel:
        return 'Request cancelled. Please try again.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please check the server configuration.';

      case DioExceptionType.unknown:
        final original = error.error;

        if (original is SocketException) {
          return 'Connection error. Please check your internet connection.';
        }

        return 'Cannot reach the server. Please check the server address or network.';

      case DioExceptionType.badResponse:
        break;
    }

    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    final backendCode = _extractBackendCode(responseData);
    final mappedCode = _mapBackendCode(backendCode);
    if (mappedCode != null) return mappedCode;

    final backendMessage = _extractBackendMessage(responseData);
    if (backendMessage != null && backendMessage.trim().isNotEmpty) {
      final mappedBackendMessage = _mapBackendCode(backendMessage);
      if (mappedBackendMessage != null) return mappedBackendMessage;

      final sanitizedBackendMessage = _sanitize(backendMessage);

      if (!_looksTechnical(sanitizedBackendMessage)) {
        return sanitizedBackendMessage;
      }
    }

    return _statusFallback(
      statusCode,
      path: error.requestOptions.path,
    );
  }

  static String _statusFallback(int? statusCode, {String? path}) {
    if (statusCode == null) {
      return 'Request failed. Please try again.';
    }

    final normalizedPath = (path ?? '').toLowerCase();
    final isLoginRequest =
        normalizedPath.contains('/auth/user/login') ||
        normalizedPath.contains('/auth/admin/login/front');

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        if (isLoginRequest) {
          return 'Login service was not found. Please check the server configuration.';
        }
        return 'Requested service was not found. Please check the server configuration.';
      case 409:
        return 'This data already exists or conflicts with another record.';
      case 422:
        return 'Some fields are invalid. Please review your input.';
      default:
        if (statusCode >= 500) {
          return 'Server error. Please try again later.';
        }

        return 'Request failed. Please try again.';
    }
  }

  static String? _extractBackendCode(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final trimmed = data.trim();

      if (_looksJson(trimmed)) {
        try {
          final decoded = json.decode(trimmed);
          return _extractBackendCode(decoded);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final code = map['code'];
      if (code is String && code.trim().isNotEmpty) {
        return code.trim();
      }

      final errorCode = map['errorCode'];
      if (errorCode is String && errorCode.trim().isNotEmpty) {
        return errorCode.trim();
      }
    }

    return null;
  }

  static String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final trimmed = data.trim();

      if (_looksJson(trimmed)) {
        try {
          final decoded = json.decode(trimmed);
          return _extractBackendMessage(decoded);
        } catch (_) {
          return trimmed;
        }
      }

      return trimmed;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in ['message', 'error', 'detail', 'msg', 'title']) {
        final value = map[key];

        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final errors = map['errors'];

      if (errors is Map) {
        final parts = <String>[];

        errors.forEach((_, value) {
          if (value is List) {
            for (final item in value) {
              if (item is String && item.trim().isNotEmpty) {
                parts.add(item.trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            parts.add(value.trim());
          }
        });

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      if (errors is List) {
        final parts = errors
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    }

    return null;
  }

  static String? _mapBackendCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final code = raw.trim().toUpperCase();

    switch (code) {
      case 'INVALID_CREDENTIALS':
      case 'WRONG_PASSWORD':
      case 'BAD_CREDENTIALS':
      case 'BUSINESS_LOGIN_FAILED':
      case 'LOGIN_FAILED':
        return 'Invalid email or password.';

      case 'USER_NOT_FOUND':
      case 'ADMIN_NOT_FOUND':
      case 'BUSINESS_NOT_FOUND':
      case 'ACCOUNT_NOT_FOUND':
        return 'Account not found.';

      case 'INVALID_EMAIL_FORMAT':
        return 'Invalid email format.';

      case 'LOGIN_LOCKED':
        return 'Too many attempts. Please try again later.';

      case 'INACTIVE':
      case 'INVALID_USER_STATUS':
      case 'ACCOUNT_INACTIVE':
        return 'Your account is inactive. Please contact support.';

      case 'NETWORK_ERROR':
      case 'CONNECTION_ERROR':
        return 'Cannot reach the server. Please check the server address or network.';

      case 'SERVER_ERROR':
      case 'INTERNAL_ERROR':
      case 'INTERNAL_SERVER_ERROR':
        return 'Server error. Please try again later.';

      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.';

      case 'ACCESS_DENIED':
      case 'FORBIDDEN':
        return 'You do not have permission to perform this action.';

      case 'MISSING_AUTH_TOKEN':
      case 'INVALID_TOKEN':
      case 'EXPIRED_TOKEN':
      case 'AUTH':
      case 'UNAUTHORIZED':
        return 'Session expired. Please log in again.';

      case 'USERNAME_ALREADY_EXISTS':
        return 'This username is already in use.';

      case 'EMAIL_ALREADY_EXISTS':
        return 'This email is already in use.';

      case 'INVALID_CODE':
        return 'Invalid verification code.';

      case 'UPLOAD_FAILED':
        return 'Upload failed. Please try again.';

      case 'INVALID_FILE_TYPE':
        return 'Invalid file type.';

      case 'NOT_FOUND':
        return 'Requested item was not found.';

      default:
        return null;
    }
  }

  static String _sanitize(String raw) {
    var message = raw.trim();

    message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    message = message.replaceFirst(RegExp(r'^AppException:\s*'), '');
    message = message.replaceFirst(RegExp(r'^DioException:\s*'), '');
    message = message.replaceFirst(RegExp(r'^Bad state:\s*'), '');

    final mappedCode = _mapBackendCode(message);
    if (mappedCode != null) return mappedCode;

    if (_looksTechnical(message)) {
      return _technicalFallback(message);
    }

    const maxLength = 180;
    if (message.length > maxLength) {
      message = '${message.substring(0, maxLength)}…';
    }

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  static bool _looksJson(String value) {
    final trimmed = value.trim();

    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  static bool _looksTechnical(String value) {
    final lower = value.toLowerCase();

    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('requestoptions') ||
        lower.contains('status code of') ||
        lower.contains('connection refused') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection timed out') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('bad response') ||
        lower.contains('stacktrace');
  }

  static String _technicalFallback(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('status code of 404') ||
        lower.contains('status code: 404')) {
      if (lower.contains('/auth/user/login') ||
          lower.contains('/auth/admin/login/front')) {
        return 'Login service was not found. Please check the server configuration.';
      }

      return 'Requested service was not found. Please check the server configuration.';
    }

    if (lower.contains('status code of 401') ||
        lower.contains('status code: 401')) {
      return 'Session expired. Please log in again.';
    }

    if (lower.contains('status code of 403') ||
        lower.contains('status code: 403')) {
      return 'You do not have permission to perform this action.';
    }

    if (lower.contains('status code of 500') ||
        lower.contains('status code: 500')) {
      return 'Server error. Please try again later.';
    }

    if (lower.contains('connection refused')) {
      return 'Cannot reach the server. Please check the server address or network.';
    }

    if (lower.contains('failed host lookup') ||
        lower.contains('socketexception')) {
      return 'Connection error. Please check your internet connection.';
    }

    if (lower.contains('connection timed out') ||
        lower.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
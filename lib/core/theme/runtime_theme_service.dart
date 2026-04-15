import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class RuntimeThemeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: const {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<String?> fetchPrimaryColorHex() async {
    final linkId = int.tryParse(AppConfig.ownerProjectLinkId);
    if (linkId == null) {
      debugPrint('RUNTIME THEME: ownerProjectLinkId is missing or invalid.');
      return null;
    }

    try {
      final headers = <String, dynamic>{};

      if (AppConfig.runtimeConfigToken.trim().isNotEmpty) {
        headers['X-Auth-Token'] = AppConfig.runtimeConfigToken.trim();
      }

      final response = await _dio.get(
        '/public/runtime-config/by-link',
        queryParameters: {
          'linkId': linkId,
        },
        options: Options(headers: headers),
      );

      debugPrint('RUNTIME THEME RESPONSE: ${response.data}');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return null;
      }

      final themeJsonString = data['THEME_JSON']?.toString();
      if (themeJsonString == null || themeJsonString.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(themeJsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final valuesMobile = decoded['valuesMobile'];
      if (valuesMobile is! Map<String, dynamic>) {
        return null;
      }

      final colors = valuesMobile['colors'];
      if (colors is! Map<String, dynamic>) {
        return null;
      }

      final primary = colors['primary']?.toString();
      if (primary == null || primary.trim().isEmpty) {
        return null;
      }

      return primary.trim();
    } on DioException catch (e) {
      debugPrint('RUNTIME THEME ERROR TYPE: ${e.type}');
      debugPrint('RUNTIME THEME ERROR MESSAGE: ${e.message}');
      debugPrint('RUNTIME THEME ERROR RESPONSE: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('RUNTIME THEME UNKNOWN ERROR: $e');
      return null;
    }
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class RuntimeAppConfig {
  final String? primaryColorHex;
  final String? appName;
  final String? logoUrl;

  const RuntimeAppConfig({
    this.primaryColorHex,
    this.appName,
    this.logoUrl,
  });
}

class RuntimeThemeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<RuntimeAppConfig?> fetchRuntimeConfig() async {
    final linkId = int.tryParse(AppConfig.ownerProjectLinkId);
    if (linkId == null) return null;

    try {
      final response = await _dio.get(
        '/public/runtime-config/by-link',
        queryParameters: {'linkId': linkId},
      );

      debugPrint('RUNTIME CONFIG RESPONSE: ${response.data}');

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final appName = data['APP_NAME']?.toString();
      final rawLogoUrl = data['LOGO_URL']?.toString();

      String? logoUrl;
      if (rawLogoUrl != null && rawLogoUrl.trim().isNotEmpty) {
        logoUrl = rawLogoUrl.startsWith('http')
            ? rawLogoUrl
            : '${AppConfig.apiBaseUrl.replaceAll('/api', '')}$rawLogoUrl';
      }

      String? primaryColor;

      final themeJsonString = data['THEME_JSON']?.toString();
      if (themeJsonString != null && themeJsonString.trim().isNotEmpty) {
        final decoded = jsonDecode(themeJsonString);
        if (decoded is Map<String, dynamic>) {
          final valuesMobile = decoded['valuesMobile'];
          if (valuesMobile is Map<String, dynamic>) {
            final colors = valuesMobile['colors'];
            if (colors is Map<String, dynamic>) {
              primaryColor = colors['primary']?.toString();
            }
          }
        }
      }

      return RuntimeAppConfig(
        primaryColorHex: primaryColor,
        appName: appName,
        logoUrl: logoUrl,
      );
    } catch (e) {
      debugPrint('RUNTIME CONFIG ERROR: $e');
      return null;
    }
  }

  Future<String?> fetchPrimaryColorHex() async {
    final config = await fetchRuntimeConfig();
    return config?.primaryColorHex;
  }
}
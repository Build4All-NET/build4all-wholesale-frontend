import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class RuntimeAppConfig {
  final String? themeJson;
  final String? themeJsonB64;
  final String? primaryColorHex;
  final String? appName;
  final String? logoUrl;

  const RuntimeAppConfig({
    this.themeJson,
    this.themeJsonB64,
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
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  Future<RuntimeAppConfig?> fetchRuntimeConfig() async {
    final linkId = int.tryParse(AppConfig.ownerProjectLinkId);

    if (linkId == null && AppConfig.runtimeConfigUrl.trim().isEmpty) {
      return _configFromEnvOnly();
    }

    try {
      final headers = <String, dynamic>{};
      if (AppConfig.runtimeConfigToken.trim().isNotEmpty) {
        headers['X-Auth-Token'] = AppConfig.runtimeConfigToken.trim();
      }

      final Response<dynamic> response;
      if (AppConfig.runtimeConfigUrl.trim().isNotEmpty) {
        response = await _dio.getUri(
          Uri.parse(AppConfig.runtimeConfigUrl.trim()),
          options: Options(headers: headers),
        );
      } else {
        response = await _dio.get(
          '/public/runtime-config/by-link',
          queryParameters: {'linkId': linkId},
          options: Options(headers: headers),
        );
      }

      debugPrint('RUNTIME CONFIG RESPONSE: ${response.data}');

      final data = response.data;
      if (data is! Map<String, dynamic>) return _configFromEnvOnly();

      final themeJsonB64 = _firstString(data, const [
        'THEME_JSON_B64',
        'themeJsonB64',
        'theme_json_b64',
      ]);

      final themeJson = _firstString(data, const [
        'THEME_JSON',
        'themeJson',
        'theme_json',
      ]);

      final appName = _firstString(data, const [
        'APP_NAME',
        'appName',
        'displayName',
        'name',
      ]);

      final rawLogoUrl = _firstString(data, const [
        'APP_LOGO_URL',
        'LOGO_URL',
        'logoUrl',
        'logoPath',
        'logo',
      ]);

      final brandingJson = _firstString(data, const [
        'BRANDING_JSON',
        'brandingJson',
        'BRANDING',
        'branding',
      ]);

      final brandingFromB64 = _decodeBrandingB64(
        _firstString(data, const [
          'BRANDING_JSON_B64',
          'brandingJsonB64',
          'branding_json_b64',
        ]),
      );

      final brandingFromJson = _decodeBrandingJson(brandingJson);

      final logoUrl = _resolveLogoUrl(
        _firstNonEmpty([
          rawLogoUrl,
          brandingFromB64?['logoPath']?.toString(),
          brandingFromB64?['logoUrl']?.toString(),
          brandingFromJson?['logoPath']?.toString(),
          brandingFromJson?['logoUrl']?.toString(),
          AppConfig.appLogoUrl,
        ]),
      );

      final primaryColor = _extractPrimaryColor(
        themeJson: themeJson,
        themeJsonB64: themeJsonB64,
      );

      return RuntimeAppConfig(
        themeJson: themeJson,
        themeJsonB64: themeJsonB64,
        primaryColorHex: primaryColor,
        appName: _firstNonEmpty([appName, AppConfig.appName]),
        logoUrl: logoUrl,
      );
    } catch (e) {
      debugPrint('RUNTIME CONFIG ERROR: $e');
      return _configFromEnvOnly();
    }
  }

  Future<String?> fetchPrimaryColorHex() async {
    final config = await fetchRuntimeConfig();
    return config?.primaryColorHex;
  }

  RuntimeAppConfig _configFromEnvOnly() {
    return RuntimeAppConfig(
      themeJson: AppConfig.themeJson,
      themeJsonB64: AppConfig.themeJsonB64,
      primaryColorHex: _extractPrimaryColor(
        themeJson: AppConfig.themeJson,
        themeJsonB64: AppConfig.themeJsonB64,
      ),
      appName: AppConfig.appName,
      logoUrl: _resolveLogoUrl(AppConfig.appLogoUrl),
    );
  }

  String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  String? _resolveLogoUrl(String? rawLogoUrl) {
    final raw = rawLogoUrl?.trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final root = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final cleanRoot = root.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = raw.startsWith('/') ? raw : '/$raw';
    return '$cleanRoot$cleanPath';
  }

  Map<String, dynamic>? _decodeBrandingB64(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      final decoded = utf8.decode(base64Decode(value.trim()));
      return _decodeBrandingJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _decodeBrandingJson(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(value.trim());
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractPrimaryColor({String? themeJson, String? themeJsonB64}) {
    Map<String, dynamic>? decoded;

    try {
      final b64 = themeJsonB64?.trim();
      if (b64 != null && b64.isNotEmpty) {
        final decodedValue = jsonDecode(utf8.decode(base64Decode(b64)));
        if (decodedValue is Map<String, dynamic>) decoded = decodedValue;
      }
    } catch (_) {
      decoded = null;
    }

    try {
      final jsonText = themeJson?.trim();
      if (decoded == null && jsonText != null && jsonText.isNotEmpty) {
        final decodedValue = jsonDecode(jsonText);
        if (decodedValue is Map<String, dynamic>) decoded = decodedValue;
      }
    } catch (_) {
      decoded = null;
    }

    final valuesMobile = decoded?['valuesMobile'];
    if (valuesMobile is! Map<String, dynamic>) return null;

    final colors = valuesMobile['colors'];
    if (colors is! Map<String, dynamic>) return null;

    return colors['primary']?.toString();
  }
}

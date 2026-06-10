class AppConfig {
  /// Build4All central backend root URL.
  /// In env this should be WITHOUT /api.
  /// Example: http://192.168.1.104:8080
  static const String apiRootUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://3.96.140.126:8080',
  );

  /// Wholesale backend root URL.
  /// In env this should be WITHOUT /api.
  /// Example: http://192.168.1.104:8083
  static const String overrideRootUrl = String.fromEnvironment(
    'OVERRIDE_BASE_URL',
    defaultValue: 'http://10.0.2.2:8082',
  );

  /// Build4All central API base URL.
  /// Result example: http://192.168.1.104:8080/api
  static String get apiBaseUrl => _withApi(apiRootUrl);

  /// Wholesale project API base URL.
  /// Result example: http://192.168.1.104:8083/api
  static String get projectApiBaseUrl => _withApi(overrideRootUrl);

  static String _withApi(String value) {
    final clean = value.trim().replaceAll(RegExp(r'/+$'), '');

    if (clean.endsWith('/api')) {
      return clean;
    }

    return '$clean/api';
  }

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'B2B Wholesale App',
  );

  /// Optional runtime/build branding logo URL.
  /// Prefer a URL or backend relative path such as /uploads/... .
  static const String appLogoUrl = String.fromEnvironment(
    'APP_LOGO_URL',
    defaultValue: '',
  );

  /// Local bundled logo asset used as a fallback when no URL is provided.
  static const String appLogoAsset = String.fromEnvironment(
    'APP_LOGO_ASSET',
    defaultValue: 'assets/branding/logo.png',
  );

  static const String appType = String.fromEnvironment(
    'APP_TYPE',
    defaultValue: 'WHOLESALE',
  );

  static const String ownerProjectLinkId = String.fromEnvironment(
    'OWNER_PROJECT_LINK_ID',
    defaultValue: '',
  );

  static const String projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: '',
  );

  static const String currencyId = String.fromEnvironment(
    'CURRENCY_ID',
    defaultValue: '',
  );

  static const String defaultLanguage = String.fromEnvironment(
    'DEFAULT_LANGUAGE',
    defaultValue: 'en',
  );

  static const String themeJsonB64 = String.fromEnvironment(
    'THEME_JSON_B64',
    defaultValue: '',
  );

  static const String themeJson = String.fromEnvironment(
    'THEME_JSON',
    defaultValue: '',
  );

  static const String navJsonB64 = String.fromEnvironment(
    'NAV_JSON_B64',
    defaultValue: '',
  );

  static const String enabledFeaturesJsonB64 = String.fromEnvironment(
    'ENABLED_FEATURES_JSON_B64',
    defaultValue: '',
  );

  static const String homeJsonB64 = String.fromEnvironment(
    'HOME_JSON_B64',
    defaultValue: '',
  );

  static const String brandingJsonB64 = String.fromEnvironment(
    'BRANDING_JSON_B64',
    defaultValue: '',
  );

  static const String menuType = String.fromEnvironment(
    'MENU_TYPE',
    defaultValue: '',
  );

  static const String runtimeConfigUrl = String.fromEnvironment(
    'RUNTIME_CONFIG_URL',
    defaultValue: '',
  );

  static const String runtimeConfigToken = String.fromEnvironment(
    'RUNTIME_CONFIG_TOKEN',
    defaultValue: '',
  );

 
}

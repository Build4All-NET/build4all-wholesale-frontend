class AppConfig {
  /// Build4All central backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://3.96.140.126:8080/api',
  );

  /// Wholesale project backend
  static const String projectApiBaseUrl = String.fromEnvironment(
    'PROJECT_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8082/api',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'B2B Wholesale App',
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

  /// Optional:
  /// only needed if /runtime-config/by-link requires X-Auth-Token
  static const String runtimeConfigToken = String.fromEnvironment(
    'RUNTIME_CONFIG_TOKEN',
    defaultValue: '',
  );
}


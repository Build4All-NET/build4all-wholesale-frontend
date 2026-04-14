class AppConfig {
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'B2B Wholesale App',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8082/api',
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
}

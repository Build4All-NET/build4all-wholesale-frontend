import '../config/app_config.dart';

class ApiConfig {
  static String get baseUrl => AppConfig.baseUrl;

  static const String login = '/auth/login';
  static const String retailerSignup = '/auth/signup/retailer';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String currentUser = '/auth/me';
  static const String supplierSync = '/auth/build4all/supplier-sync';

  static const String supplierProfile = '/supplier-profile';
  static String retailerProfile(int userId) => '/retailer-profile/$userId';
}

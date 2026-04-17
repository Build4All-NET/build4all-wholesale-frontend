import '../config/app_config.dart';

class ApiConfig {
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static String get projectApiBaseUrl => AppConfig.projectApiBaseUrl;

  // ----------------------------
  // Build4All central endpoints
  // ----------------------------
  static const String adminLoginFront = '/auth/admin/login/front';
  static const String userLogin = '/auth/user/login';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyEmailCode = '/auth/verify-email-code';
  static const String completeProfile = '/auth/complete-profile';

  // ----------------------------
  // Wholesale project endpoints
  // ----------------------------
  static const String login = '/auth/login';
  static const String retailerSignup = '/auth/signup/retailer';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String currentUser = '/auth/me';
  static const String supplierSync = '/auth/build4all/supplier-sync';
  static const String retailerSync = '/auth/build4all/retailer-sync';

  static const String supplierProfile = '/supplier-profile';
  static String retailerProfile(int userId) => '/retailer-profile/$userId';
}
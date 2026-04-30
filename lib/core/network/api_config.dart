import '../config/app_config.dart';

class ApiConfig {
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static String get projectApiBaseUrl => AppConfig.projectApiBaseUrl;

  static const String adminLoginFront = '/auth/admin/login/front';
  static const String userLogin = '/auth/user/login';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyEmailCode = '/auth/verify-email-code';
  static const String completeProfile = '/auth/complete-profile';

  static const String currentUser = '/auth/me';
  static const String supplierSync = '/auth/build4all/supplier-sync';
  static const String retailerSync = '/auth/build4all/retailer-sync';

  static const String supplierProfile = '/supplier-profile';
  static const String supplierProfileMe = '/supplier-profile/me';
  static const String retailerProfileMe = '/retailer-profile/me';

  // Retailer Home endpoints from Wholesale backend
  static const String retailerHome = '/retailer-home';
  static const String retailerHomeAddCartItem = '/retailer-home/cart/items';

  static String build4AllUserById(int id) => '/users/$id';
  static String build4AllUserProfile(int id) => '/users/$id/profile';
}

import '../config/app_config.dart';

class ApiConfig {
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static String get projectApiBaseUrl => AppConfig.projectApiBaseUrl;

  static const String adminLoginFront = '/auth/admin/login/front';
  static const String userLogin = '/auth/user/login';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyEmailCode = '/auth/verify-email-code';
  static const String completeProfile = '/auth/complete-profile';

  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String currentUser = '/auth/me';
  static const String supplierSync = '/auth/build4all/supplier-sync';
  static const String retailerSync = '/auth/build4all/retailer-sync';

  static const String supplierProfile = '/supplier-profile';
  static const String supplierProfileMe = '/supplier-profile/me';
  static const String retailerProfileMe = '/retailer-profile/me';
    // Supplier Categories
  static const String supplierCategories = '/supplier/categories';
  static const String supplierSubCategories = '/supplier/subcategories';

  static String supplierCategoryById(String id) {
    return '/supplier/categories/$id';
  }

  static String supplierSubCategoryById(String id) {
    return '/supplier/subcategories/$id';
  }

  static String supplierSubCategoriesByCategory(String categoryId) {
    return '/supplier/subcategories/category/$categoryId';
  }
    // Supplier Branches
  static const String supplierBranches = '/supplier/branches';

  static String supplierBranchById(String id) {
    return '/supplier/branches/$id';
  }

  static String supplierBranchesSearch(String query) {
    return '/supplier/branches/search?query=$query';
  }
    // Supplier Products
  static const String supplierProducts = '/supplier/products';

  static String supplierProductById(String id) {
    return '/supplier/products/$id';
  }

  static String supplierProductsSearch(String query) {
    return '/supplier/products/search?query=$query';
  }
    // Supplier Branch Inventory
  static const String supplierBranchInventory = '/supplier/branch-inventory';

  static String supplierInventoryByBranch(String branchId) {
    return '/supplier/branch-inventory/branch/$branchId';
  }

  static String supplierInventoryByProduct(String productId) {
    return '/supplier/branch-inventory/product/$productId';
  }

  static String supplierInventoryStockById(String inventoryId) {
    return '/supplier/branch-inventory/$inventoryId/stock';
  }

  static String supplierInventoryById(String inventoryId) {
    return '/supplier/branch-inventory/$inventoryId';
  }

  static String supplierBranchInventorySummary(String branchId) {
    return '/supplier/branch-inventory/branch/$branchId/summary';
  }

  static String supplierProductInventorySummary(String productId) {
    return '/supplier/branch-inventory/product/$productId/summary';
  }
}
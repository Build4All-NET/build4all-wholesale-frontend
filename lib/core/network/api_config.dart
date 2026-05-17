import '../config/app_config.dart';

class ApiConfig {
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static String get projectApiBaseUrl => AppConfig.projectApiBaseUrl;

  // =========================
  // Build4All / Auth
  // =========================
  static const String adminLoginFront = '/auth/admin/login/front';
  static const String userLogin = '/auth/user/login';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyEmailCode = '/auth/verify-email-code';
  static const String completeProfile = '/auth/complete-profile';

  static const String build4AllAdminProfileMe = '/admin/users/me';

  static const String currentUser = '/auth/me';
  static const String supplierSync = '/auth/build4all/supplier-sync';
  static const String retailerSync = '/auth/build4all/retailer-sync';

  // =========================
  // Profiles
  // =========================
  static const String supplierProfile = '/supplier-profile';
  static const String supplierProfileMe = '/supplier-profile/me';
  static const String retailerProfileMe = '/retailer-profile/me';

  // =========================
  // Shared Catalog: Countries / Regions
  // =========================
  static const String countries = '/countries';
  static const String regions = '/regions';

  static String regionsByCountry(String countryId) {
    return '/regions/country/$countryId';
  }

  // =========================
  // Retailer Home
  // =========================
  static const String retailerHome = '/retailer-home';
  static const String retailerHomeAddCartItem = '/retailer-home/cart/items';

  static String retailerHomeCategoryProducts(int categoryId) =>
      '/retailer-home/categories/$categoryId/products';

  // =========================
  // Retailer Cart
  // =========================
  static const String retailerCart = '/retailer/cart';
  static const String retailerCartItems = '/retailer/cart/items';
  static const String retailerBanners = '/retailer/banners';

  static String retailerCartItemById(int cartItemId) =>
      '/retailer/cart/items/$cartItemId';

  // =========================
  // Build4All user endpoints
  // =========================
  static String build4AllUserById(int id) => '/users/$id';

  static String build4AllUserProfile(int id) => '/users/$id/profile';

  static String build4AllVerifyEmailChange(int id) =>
      '/users/$id/email-change/verify';

  static String build4AllResendEmailChange(int id) =>
      '/users/$id/email-change/resend';

  static String build4AllResetPassword(int ownerProjectLinkId) =>
      '/users/reset-password?ownerProjectLinkId=$ownerProjectLinkId';

  static String build4AllVerifyResetCode(int ownerProjectLinkId) =>
      '/users/verify-reset-code?ownerProjectLinkId=$ownerProjectLinkId';

  static String build4AllUpdatePassword(int ownerProjectLinkId) =>
      '/users/update-password?ownerProjectLinkId=$ownerProjectLinkId';

  static String build4AllDeleteUser(int userId) => '/users/$userId';

  // =========================
  // Supplier Categories
  // =========================
  static const String supplierCategories = '/supplier/categories';
  static const String supplierCategoriesAll = '/supplier/categories/all';
  static const String supplierSubCategories = '/supplier/subcategories';
  static const String supplierSubCategoriesAll = '/supplier/subcategories/all';

  static String supplierCategoryById(String id) {
    return '/supplier/categories/$id';
  }

  static String supplierCategoryStatus(String id, String status) {
    return '/supplier/categories/$id/status?status=$status';
  }

  static String supplierSubCategoryById(String id) {
    return '/supplier/subcategories/$id';
  }

  static String supplierSubCategoryStatus(String id, String status) {
    return '/supplier/subcategories/$id/status?status=$status';
  }

  static String supplierSubCategoriesByCategory(String categoryId) {
    return '/supplier/subcategories/category/$categoryId';
  }

  // =========================
  // Supplier Branches
  // =========================
  static const String supplierBranches = '/supplier/branches';

  static String supplierBranchById(String id) {
    return '/supplier/branches/$id';
  }

  static String supplierBranchesSearch(String query) {
    return '/supplier/branches/search?query=$query';
  }

  // =========================
  // Supplier Products
  // =========================
  static const String supplierProducts = '/supplier/products';
  static const String supplierProductImageUpload = '/supplier/products/image';

  static String supplierProductById(String id) {
    return '/supplier/products/$id';
  }

  static String supplierProductsSearch(String query) {
    return '/supplier/products/search?query=$query';
  }

  // =========================
  // Supplier Branch Inventory
  // =========================
  static const String supplierBranchInventory = '/supplier/branch-inventory';
  static const String supplierLowStockAlerts =
      '/supplier/branch-inventory/low-stock?threshold=50';

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

  // =========================
  // Supplier Coupons
  // =========================
  static const String supplierCoupons = '/supplier/coupons';

  static String supplierCouponById(String id) {
    return '/supplier/coupons/$id';
  }

  // =========================
  // Supplier Promotions
  // =========================
  static const String supplierPromotions = '/supplier/promotions';

  static String supplierPromotionById(String id) {
    return '/supplier/promotions/$id';
  }

  // =========================
  // Supplier Home Banners
  // =========================
  static const String supplierBanners = '/supplier/banners';

  static const String supplierBannerUploadImage =
      '/supplier/banners/upload-image';

  static String supplierBannerById(String id) {
    return '/supplier/banners/$id';
  }

  // =========================
  // Supplier Shipping Methods
  // =========================
  static const String supplierShippingMethods = '/supplier/shipping-methods';

  static String supplierShippingMethodById(String id) {
    return '/supplier/shipping-methods/$id';
  }

  // =========================
  // SUPPLIER TAX RULES
  // =========================
  static const String supplierTaxRules = '/supplier/tax-rules';

  static String supplierTaxRuleById(String id) {
    return '/supplier/tax-rules/$id';
  }

  static const String supplierTaxPreview = '/supplier/tax-rules/preview';

  // =========================
  // Supplier Orders
  // =========================
  static const String supplierOrders = '/supplier/orders';

  static String supplierOrdersByStatus(String status) {
    return '/supplier/orders/status/$status';
  }

  static String supplierOrderById(String orderId) {
    return '/supplier/orders/$orderId';
  }

  static String supplierOrderStatus(String orderId) {
    return '/supplier/orders/$orderId/status';
  }

  // =========================
  // Supplier RFQ
  // =========================
  static const String supplierRfqsOpen = '/supplier/rfqs/open';

  static String supplierRfqById(int rfqId) {
    return '/supplier/rfqs/$rfqId';
  }

  static String submitSupplierRfqQuotation(int rfqId) {
    return '/supplier/rfqs/$rfqId/quotations';
  }

  static String updateSupplierRfqQuotation(int quotationId) {
    return '/supplier/rfqs/quotations/$quotationId';
  }

  static String withdrawSupplierRfqQuotation(int quotationId) {
    return '/supplier/rfqs/quotations/$quotationId/withdraw';
  }

  // =========================
  // Retailer RFQ
  // =========================
  static const String retailerRfqs = '/retailer/rfqs';
  static const String retailerRfqImageUpload = '/retailer/rfqs/image';

  static String retailerRfqById(int rfqId) {
    return '/retailer/rfqs/$rfqId';
  }

  static String submitRetailerRfq(int rfqId) {
    return '/retailer/rfqs/$rfqId/submit';
  }

  static String cancelRetailerRfq(int rfqId) {
    return '/retailer/rfqs/$rfqId/cancel';
  }

  static String retailerRfqQuotations(int rfqId) {
    return '/retailer/rfqs/$rfqId/quotations';
  }

  static String acceptRetailerRfqQuotation(int rfqId, int quotationId) {
    return '/retailer/rfqs/$rfqId/quotations/$quotationId/accept';
  }

  // =========================
  // Retailer Product AI
  // =========================
  static String retailerProductAiChat(int productId) =>
      '/retailer-ai/products/$productId/chat';
  // =========================
  // Retailer RFQ AI
  // =========================
  static const String retailerRfqAiRequirements =
      '/retailer-ai/rfq/requirements';
}

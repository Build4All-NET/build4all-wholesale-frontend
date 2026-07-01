import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/auth/session_manager.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_refresh_service.dart';
import 'core/network/connectivity_monitor.dart';
import 'core/storage/auth_storage.dart';
import 'core/storage/theme_storage.dart';
import 'core/storage/locale_storage.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/runtime_theme_service.dart';

// =========================
// CORE CURRENCY
// =========================
import 'core/currency/data/app_currency_api_service.dart';
import 'core/currency/data/app_currency_repository_impl.dart';
import 'core/currency/domain/app_currency_repository.dart';
import 'core/currency/domain/get_project_currency_usecase.dart';
import 'core/currency/presentation/app_currency_cubit.dart';

// =========================
// RETAILER PRODUCT AI
// =========================
import 'features/retailer/product_ai/data/repositories/retailer_product_ai_repository_impl.dart';
import 'features/retailer/product_ai/data/services/retailer_product_ai_service.dart';
import 'features/retailer/product_ai/domain/repositories/retailer_product_ai_repository.dart';
import 'features/retailer/product_ai/presentation/cubit/retailer_product_ai_cubit.dart';

// =========================
// AUTH
// =========================
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/retailer_signup_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

// =========================
// NOTIFICATIONS (shared notify library)
// =========================
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/data/services/notification_api_service.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';

// =========================
// SUPPLIER LICENSING (build4all subscription/upgrade)
// =========================
import 'features/supplier/licensing/data/repositories/licensing_repository_impl.dart';
import 'features/supplier/licensing/data/services/licensing_api_service.dart';
import 'features/supplier/licensing/domain/repositories/i_licensing_repository.dart';
import 'features/supplier/licensing/domain/usecases/licensing_usecases.dart';
import 'features/supplier/licensing/presentation/bloc/upgrade_flow_bloc.dart';
import 'features/supplier/licensing/presentation/cubit/supplier_subscription_cubit.dart';

// =========================
// SUPPLIER PROFILE
// =========================
import 'features/supplier_profile/data/repositories/supplier_profile_repository_impl.dart';
import 'features/supplier_profile/data/services/supplier_profile_service.dart';
import 'features/supplier_profile/domain/repositories/supplier_profile_repository.dart';
import 'features/supplier_profile/domain/usecases/create_supplier_profile_usecase.dart';
import 'features/supplier_profile/presentation/bloc/supplier_profile_cubit.dart';

// =========================
// SUPPLIER PROFILE DISPLAY - BUILD4ALL READ ONLY
// =========================
import 'features/supplier/profile/data/repositories/supplier_profile_display_repository_impl.dart';
import 'features/supplier/profile/data/services/supplier_profile_display_api_service.dart';
import 'features/supplier/profile/domain/repositories/supplier_profile_display_repository.dart';
import 'features/supplier/profile/domain/usecases/get_supplier_profile_display_usecase.dart';
import 'features/supplier/profile/presentation/bloc/supplier_profile_display_bloc.dart';

// =========================
// RETAILER HOME / PROFILE / CART
// =========================
import 'features/dashboard/data/services/retailer_home_service.dart';
import 'features/dashboard/data/repositories/retailer_home_repository_impl.dart';
import 'features/dashboard/domain/repositories/retailer_home_repository.dart';
import 'features/dashboard/presentation/cubit/retailer_home_cubit.dart';

import 'features/retailer_profile/data/services/retailer_profile_service.dart';
import 'features/retailer_profile/data/repositories/retailer_profile_repository_impl.dart';
import 'features/retailer_profile/domain/repositories/retailer_profile_repository.dart';
import 'features/retailer_profile/presentation/cubit/retailer_profile_cubit.dart';

import 'features/retailer/cart/data/services/retailer_cart_service.dart';
import 'features/retailer/cart/presentation/cubit/retailer_cart_cubit.dart';
import 'features/retailer/checkout/data/services/retailer_checkout_api_service.dart';
import 'features/retailer/checkout/presentation/cubit/retailer_checkout_cubit.dart';

// =========================
// RETAILER ORDERS
// =========================
import 'features/retailer/orders/data/repositories/retailer_order_repository_impl.dart';
import 'features/retailer/orders/data/services/retailer_order_api_service.dart';
import 'features/retailer/orders/domain/repositories/retailer_order_repository.dart';
import 'features/retailer/orders/domain/usecases/cancel_retailer_order_usecase.dart';
import 'features/retailer/orders/domain/usecases/get_retailer_order_details_usecase.dart';
import 'features/retailer/orders/domain/usecases/get_retailer_orders_usecase.dart';
import 'features/retailer/orders/domain/usecases/reorder_retailer_order_usecase.dart';
import 'features/retailer/orders/presentation/cubit/retailer_orders_cubit.dart';

// =========================
// RETAILER RFQ
// =========================
import 'features/retailer/rfq/data/repositories/retailer_rfq_repository_impl.dart';
import 'features/retailer/rfq/data/services/retailer_rfq_api_service.dart';
import 'features/retailer/rfq/domain/repositories/retailer_rfq_repository.dart';
import 'features/retailer/rfq/domain/usecases/accept_rfq_quotation_usecase.dart';
import 'features/retailer/rfq/domain/usecases/cancel_rfq_usecase.dart';
import 'features/retailer/rfq/domain/usecases/create_rfq_usecase.dart';
import 'features/retailer/rfq/domain/usecases/delete_rfq_usecase.dart';
import 'features/retailer/rfq/domain/usecases/generate_rfq_requirements_usecase.dart';
import 'features/retailer/rfq/domain/usecases/get_my_rfqs_usecase.dart';
import 'features/retailer/rfq/domain/usecases/get_rfq_details_usecase.dart';
import 'features/retailer/rfq/domain/usecases/update_rfq_usecase.dart';
import 'features/retailer/rfq/presentation/cubit/retailer_rfq_cubit.dart';

// =========================
// SUPPLIER RFQ
// =========================
import 'features/supplier/rfq/data/repositories/supplier_rfq_repository_impl.dart';
import 'features/supplier/rfq/data/services/supplier_rfq_api_service.dart';
import 'features/supplier/rfq/domain/repositories/supplier_rfq_repository.dart';
import 'features/supplier/rfq/domain/usecases/get_open_supplier_rfqs_usecase.dart';
import 'features/supplier/rfq/domain/usecases/get_supplier_rfq_details_usecase.dart';
import 'features/supplier/rfq/domain/usecases/submit_supplier_rfq_quotation_usecase.dart';
import 'features/supplier/rfq/domain/usecases/update_supplier_rfq_quotation_usecase.dart';
import 'features/supplier/rfq/domain/usecases/withdraw_supplier_rfq_quotation_usecase.dart';
import 'features/supplier/rfq/presentation/cubit/supplier_rfq_cubit.dart';

// =========================
// SUPPLIER CATEGORIES / CATALOG
// =========================
import 'features/supplier/categories/data/repositories/supplier_category_repository_impl.dart';
import 'features/supplier/categories/data/services/supplier_category_api_service.dart';
import 'features/supplier/categories/domain/repositories/supplier_category_repository.dart';

import 'features/supplier/categories/domain/usecases/get_categories_usecase.dart';
import 'features/supplier/categories/domain/usecases/get_all_categories_usecase.dart';
import 'features/supplier/categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/get_all_subcategories_usecase.dart';
import 'features/supplier/categories/domain/usecases/create_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/update_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/update_category_status_usecase.dart';
import 'features/supplier/categories/domain/usecases/delete_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/create_subcategory_usecase.dart';
import 'features/supplier/categories/domain/usecases/update_subcategory_usecase.dart';
import 'features/supplier/categories/domain/usecases/update_subcategory_status_usecase.dart';
import 'features/supplier/categories/domain/usecases/delete_subcategory_usecase.dart';

import 'features/supplier/categories/presentation/bloc/supplier_catalog/supplier_catalog_bloc.dart';

// =========================
// SUPPLIER BRANCHES
// =========================
import 'features/supplier/branches/data/repositories/branch_repository_impl.dart';
import 'features/supplier/branches/data/services/branch_api_service.dart';
import 'features/supplier/branches/domain/repositories/branch_repository.dart';

import 'features/supplier/branches/domain/usecases/get_branches_usecase.dart';
import 'features/supplier/branches/domain/usecases/search_branches_usecase.dart';
import 'features/supplier/branches/domain/usecases/create_branch_usecase.dart';
import 'features/supplier/branches/domain/usecases/update_branch_usecase.dart';
import 'features/supplier/branches/domain/usecases/delete_branch_usecase.dart';

// =========================
// SUPPLIER BRANCH INVENTORY
// =========================
import 'features/supplier/branches/data/repositories/branch_inventory_repository_impl.dart';
import 'features/supplier/branches/data/services/branch_inventory_api_service.dart';
import 'features/supplier/branches/domain/repositories/branch_inventory_repository.dart';

import 'features/supplier/branches/domain/usecases/get_inventory_by_branch_usecase.dart';
import 'features/supplier/branches/domain/usecases/get_inventory_by_product_usecase.dart';
import 'features/supplier/branches/domain/usecases/assign_product_to_branch_usecase.dart';
import 'features/supplier/branches/domain/usecases/update_branch_stock_usecase.dart';
import 'features/supplier/branches/domain/usecases/delete_inventory_item_usecase.dart';

// =========================
// SUPPLIER PRODUCTS
// =========================
import 'features/supplier/products/data/repositories/product_repository_impl.dart';
import 'features/supplier/products/data/services/product_api_service.dart';
import 'features/supplier/products/domain/repositories/product_repository.dart';

import 'features/supplier/products/domain/usecases/get_products_usecase.dart';
import 'features/supplier/products/domain/usecases/search_products_usecase.dart';
import 'features/supplier/products/domain/usecases/create_product_usecase.dart';
import 'features/supplier/products/domain/usecases/update_product_usecase.dart';
import 'features/supplier/products/domain/usecases/delete_product_usecase.dart';

import 'features/supplier/products/presentation/bloc/product_list/product_list_bloc.dart';
import 'features/supplier/branches/presentation/bloc/branch_list/branch_list_bloc.dart';
import 'features/supplier/branches/presentation/bloc/branch_inventory/branch_inventory_bloc.dart';
import 'features/supplier/products/presentation/bloc/product_branch_inventory/product_branch_inventory_bloc.dart';

// =========================
// SUPPLIER COUPONS
// =========================
import 'features/supplier/coupons/data/repositories/coupon_repository_impl.dart';
import 'features/supplier/coupons/data/services/coupon_api_service.dart';
import 'features/supplier/coupons/domain/repositories/coupon_repository.dart';
import 'features/supplier/coupons/domain/usecases/create_coupon_usecase.dart';
import 'features/supplier/coupons/domain/usecases/delete_coupon_usecase.dart';
import 'features/supplier/coupons/domain/usecases/get_coupons_usecase.dart';
import 'features/supplier/coupons/domain/usecases/update_coupon_usecase.dart';
import 'features/supplier/coupons/presentation/bloc/coupons_bloc.dart';

// =========================
// SUPPLIER PROMOTIONS
// =========================
import 'features/supplier/promotions/data/repositories/promotion_repository_impl.dart';
import 'features/supplier/promotions/data/services/promotion_api_service.dart';
import 'features/supplier/promotions/domain/repositories/promotion_repository.dart';
import 'features/supplier/promotions/domain/usecases/create_promotion_usecase.dart';
import 'features/supplier/promotions/domain/usecases/delete_promotion_usecase.dart';
import 'features/supplier/promotions/domain/usecases/get_promotions_usecase.dart';
import 'features/supplier/promotions/domain/usecases/update_promotion_usecase.dart';
import 'features/supplier/promotions/presentation/bloc/promotions_bloc.dart';

// =========================
// SUPPLIER BANNERS
// =========================
import 'features/supplier/banners/data/repositories/banner_repository_impl.dart';
import 'features/supplier/banners/data/services/banner_api_service.dart';
import 'features/supplier/banners/data/services/banner_image_upload_service.dart';
import 'features/supplier/banners/domain/repositories/banner_repository.dart';
import 'features/supplier/banners/domain/usecases/create_banner_usecase.dart';
import 'features/supplier/banners/domain/usecases/delete_banner_usecase.dart';
import 'features/supplier/banners/domain/usecases/get_banners_usecase.dart';
import 'features/supplier/banners/domain/usecases/update_banner_usecase.dart';
import 'features/supplier/banners/presentation/bloc/banners_bloc.dart';

// =========================
// SUPPLIER SHIPPING METHODS
// =========================
import 'features/supplier/shipping/data/repositories/shipping_method_repository_impl.dart';
import 'features/supplier/shipping/data/services/shipping_method_api_service.dart';
import 'features/supplier/shipping/data/services/shipping_location_api_service.dart';
import 'features/supplier/shipping/domain/repositories/shipping_method_repository.dart';
import 'features/supplier/shipping/domain/usecases/create_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/delete_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/get_shipping_methods_usecase.dart';
import 'features/supplier/shipping/domain/usecases/update_shipping_method_usecase.dart';
import 'features/supplier/shipping/presentation/bloc/shipping_methods_bloc.dart';

// =========================
// SUPPLIER TAX
// =========================
import 'features/supplier/tax/data/repositories/tax_rule_repository_impl.dart';
import 'features/supplier/tax/data/services/tax_rule_api_service.dart';
import 'features/supplier/tax/domain/repositories/tax_rule_repository.dart';
import 'features/supplier/tax/domain/usecases/create_tax_rule_usecase.dart';
import 'features/supplier/tax/domain/usecases/delete_tax_rule_usecase.dart';
import 'features/supplier/tax/domain/usecases/get_tax_rules_usecase.dart';
import 'features/supplier/tax/domain/usecases/preview_tax_usecase.dart';
import 'features/supplier/tax/domain/usecases/update_tax_rule_usecase.dart';
import 'features/supplier/tax/presentation/bloc/tax_rules_bloc.dart';

// =========================
// SUPPLIER EXCEL IMPORT
// =========================
import 'features/supplier/excel_import/data/repositories/supplier_excel_import_repository_impl.dart';
import 'features/supplier/excel_import/data/services/supplier_excel_reader_service.dart';
import 'features/supplier/excel_import/domain/repositories/supplier_excel_import_repository.dart';
import 'features/supplier/excel_import/domain/usecases/clear_supplier_excel_import_usecase.dart';
import 'features/supplier/excel_import/domain/usecases/import_supplier_excel_products_usecase.dart';
import 'features/supplier/excel_import/domain/usecases/parse_supplier_excel_file_usecase.dart';
import 'features/supplier/excel_import/domain/usecases/pick_supplier_excel_file_usecase.dart';
import 'features/supplier/excel_import/domain/usecases/validate_supplier_excel_rows_usecase.dart';
import 'features/supplier/excel_import/presentation/bloc/supplier_excel_import_bloc.dart';

// =========================
// SUPPLIER ORDERS
// =========================
import 'features/supplier/orders/data/repositories/supplier_order_repository_impl.dart';
import 'features/supplier/orders/data/services/supplier_order_api_service.dart';
import 'features/supplier/orders/domain/repositories/supplier_order_repository.dart';
import 'features/supplier/orders/domain/usecases/get_supplier_orders_usecase.dart';
import 'features/supplier/orders/domain/usecases/get_supplier_order_details_usecase.dart';
import 'features/supplier/orders/domain/usecases/update_supplier_order_status_usecase.dart';
import 'features/supplier/orders/presentation/bloc/supplier_orders/supplier_orders_bloc.dart';
import 'features/supplier/orders/presentation/bloc/supplier_order_details/supplier_order_details_bloc.dart';
import 'features/supplier/payment/data/repositories/supplier_payment_repository_impl.dart';
import 'features/supplier/payment/data/services/supplier_payment_api_service.dart';
import 'features/supplier/payment/domain/repositories/supplier_payment_repository.dart';
import 'features/supplier/payment/domain/usecases/get_supplier_order_payment_usecase.dart';
import 'features/supplier/payment/domain/usecases/mark_supplier_cash_payment_paid_usecase.dart';

// =========================
// SUPPLIER DASHBOARD
// =========================
import 'features/supplier/dashboard/data/repositories/supplier_dashboard_repository_impl.dart';
import 'features/supplier/dashboard/data/services/supplier_dashboard_api_service.dart';
import 'features/supplier/dashboard/domain/repositories/supplier_dashboard_repository.dart';
import 'features/supplier/dashboard/domain/usecases/get_supplier_low_stock_alerts_usecase.dart';
import 'features/supplier/dashboard/presentation/bloc/supplier_dashboard/supplier_dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================
  // CORE / STORAGE
  // =========================
  sl.registerLazySingleton<AuthStorage>(() => AuthStorage());
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage());
  sl.registerLazySingleton<LocaleStorage>(() => LocaleStorage());

  // =========================
  // CORE / NETWORK
  // =========================
  // Rotates the access token against the central build4all backend. Shared by
  // both API clients so a 401 from either side recovers the same session.
  sl.registerLazySingleton<AuthRefreshService>(
    () => AuthRefreshService(
      sl<AuthStorage>(),
      centralBaseUrl: AppConfig.apiBaseUrl,
    ),
  );

  // Resolved lazily at call time (only when a refresh token is finally
  // rejected), so there is no construction-time cycle with SessionManager,
  // which itself depends on AuthService -> ApiClient.
  void onSessionExpired() => sl<SessionManager>().onSessionExpired();

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<AuthStorage>(),
      baseUrl: AppConfig.apiBaseUrl,
      refreshService: sl<AuthRefreshService>(),
      onSessionExpired: onSessionExpired,
    ),
    instanceName: 'centralApiClient',
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<AuthStorage>(),
      baseUrl: AppConfig.projectApiBaseUrl,
      refreshService: sl<AuthRefreshService>(),
      onSessionExpired: onSessionExpired,
    ),
    instanceName: 'projectApiClient',
  );

  // Drops stale HTTP connections the instant the network changes
  // (Wi-Fi <-> mobile data) so requests don't hang on dead sockets.
  sl.registerLazySingleton<ConnectivityMonitor>(
    () => ConnectivityMonitor([
      sl<ApiClient>(instanceName: 'centralApiClient'),
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ]),
  );

  // =========================
  // THEME / LOCALE
  // =========================
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<ThemeStorage>()));

  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<LocaleStorage>()));

  sl.registerLazySingleton<RuntimeThemeService>(() => RuntimeThemeService());

  sl.registerLazySingleton<AppCurrencyApiService>(
    () => AppCurrencyApiService(
      sl<ApiClient>(instanceName: 'centralApiClient'),
    ),
  );

  // =========================
  // SERVICES
  // =========================
  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      centralApiClient: sl<ApiClient>(instanceName: 'centralApiClient'),
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  // Single source of truth for auth state; the router listens to it.
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
      authService: sl<AuthService>(),
    ),
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      authStorage: sl<AuthStorage>(),
      authService: sl<AuthService>(),
      onAuthenticated: () =>
          sl<PushNotificationService>().registerForCurrentUser(),
      onSignedOut: () => sl<PushNotificationService>().unregister(),
    ),
  );

  sl.registerLazySingleton<RetailerHomeService>(
    () => RetailerHomeService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<RetailerCartService>(
    () => RetailerCartService(
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<RetailerRfqApiService>(
    () =>
        RetailerRfqApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<RetailerOrderApiService>(
    () => RetailerOrderApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierRfqApiService>(
    () =>
        SupplierRfqApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<SupplierProfileService>(
    () =>
        SupplierProfileService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<SupplierProfileDisplayApiService>(
    () => SupplierProfileDisplayApiService(
      sl<ApiClient>(instanceName: 'centralApiClient'),
    ),
  );

  sl.registerLazySingleton<RetailerProfileService>(
    () => RetailerProfileService(
      centralApiClient: sl<ApiClient>(instanceName: 'centralApiClient'),
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierCategoryApiService>(
    () => SupplierCategoryApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<BranchApiService>(
    () => BranchApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<ProductApiService>(
    () => ProductApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<SupplierExcelReaderService>(
    () => SupplierExcelReaderService(),
  );

  sl.registerLazySingleton<BranchInventoryApiService>(
    () => BranchInventoryApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<CouponApiService>(
    () => CouponApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<PromotionApiService>(
    () => PromotionApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<BannerApiService>(
    () => BannerApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<BannerImageUploadService>(
    () => BannerImageUploadService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<ShippingMethodApiService>(
    () => ShippingMethodApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<ShippingLocationApiService>(
    () => ShippingLocationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<TaxRuleApiService>(
    () => TaxRuleApiService(sl<ApiClient>(instanceName: 'projectApiClient')),
  );

  sl.registerLazySingleton<SupplierOrderApiService>(
    () => SupplierOrderApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierPaymentApiService>(
    () => SupplierPaymentApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierDashboardApiService>(
    () => SupplierDashboardApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<RetailerProductAiService>(
    () => RetailerProductAiService(
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<RetailerCheckoutApiService>(
    () => RetailerCheckoutApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  // =========================
  // REPOSITORIES
  // =========================
  sl.registerLazySingleton<AppCurrencyRepository>(
    () => AppCurrencyRepositoryImpl(
      apiService: sl<AppCurrencyApiService>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: sl<AuthService>(),
      authStorage: sl<AuthStorage>(),
    ),
  );

  sl.registerLazySingleton<SupplierProfileRepository>(
    () => SupplierProfileRepositoryImpl(
      supplierProfileService: sl<SupplierProfileService>(),
    ),
  );

  sl.registerLazySingleton<SupplierProfileDisplayRepository>(
    () => SupplierProfileDisplayRepositoryImpl(
      apiService: sl<SupplierProfileDisplayApiService>(),
    ),
  );

  sl.registerLazySingleton<RetailerHomeRepository>(
    () => RetailerHomeRepositoryImpl(
      retailerHomeService: sl<RetailerHomeService>(),
    ),
  );

  sl.registerLazySingleton<RetailerProfileRepository>(
    () => RetailerProfileRepositoryImpl(
      retailerProfileService: sl<RetailerProfileService>(),
      authStorage: sl<AuthStorage>(),
    ),
  );

  sl.registerLazySingleton<RetailerRfqRepository>(
    () => RetailerRfqRepositoryImpl(apiService: sl<RetailerRfqApiService>()),
  );

  sl.registerLazySingleton<RetailerOrderRepository>(
    () =>
        RetailerOrderRepositoryImpl(apiService: sl<RetailerOrderApiService>()),
  );

  sl.registerLazySingleton<SupplierRfqRepository>(
    () => SupplierRfqRepositoryImpl(apiService: sl<SupplierRfqApiService>()),
  );

  sl.registerLazySingleton<RetailerProductAiRepository>(
    () => RetailerProductAiRepositoryImpl(
      retailerProductAiService: sl<RetailerProductAiService>(),
    ),
  );

  sl.registerLazySingleton<SupplierCategoryRepository>(
    () => SupplierCategoryRepositoryImpl(
      apiService: sl<SupplierCategoryApiService>(),
    ),
  );

  sl.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImpl(apiService: sl<BranchApiService>()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(apiService: sl<ProductApiService>()),
  );

  sl.registerLazySingleton<SupplierExcelImportRepository>(
    () => SupplierExcelImportRepositoryImpl(
      readerService: sl<SupplierExcelReaderService>(),
    ),
  );

  sl.registerLazySingleton<BranchInventoryRepository>(
    () => BranchInventoryRepositoryImpl(
      apiService: sl<BranchInventoryApiService>(),
    ),
  );

  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(apiService: sl<CouponApiService>()),
  );

  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(apiService: sl<PromotionApiService>()),
  );

  sl.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(apiService: sl<BannerApiService>()),
  );

  sl.registerLazySingleton<ShippingMethodRepository>(
    () => ShippingMethodRepositoryImpl(
      apiService: sl<ShippingMethodApiService>(),
    ),
  );

  sl.registerLazySingleton<TaxRuleRepository>(
    () => TaxRuleRepositoryImpl(apiService: sl<TaxRuleApiService>()),
  );

  sl.registerLazySingleton<SupplierOrderRepository>(
    () =>
        SupplierOrderRepositoryImpl(apiService: sl<SupplierOrderApiService>()),
  );

  sl.registerLazySingleton<SupplierPaymentRepository>(
    () => SupplierPaymentRepositoryImpl(
      apiService: sl<SupplierPaymentApiService>(),
    ),
  );

  sl.registerLazySingleton<SupplierDashboardRepository>(
    () => SupplierDashboardRepositoryImpl(
      apiService: sl<SupplierDashboardApiService>(),
    ),
  );

  sl.registerLazySingleton<GetProjectCurrencyUseCase>(
    () => GetProjectCurrencyUseCase(sl<AppCurrencyRepository>()),
  );

  // =========================
  // RETAILER RFQ USE CASES
  // =========================
  sl.registerLazySingleton<GetMyRfqsUseCase>(
    () => GetMyRfqsUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<GetRfqDetailsUseCase>(
    () => GetRfqDetailsUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<CreateRfqUseCase>(
    () => CreateRfqUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<UpdateRfqUseCase>(
    () => UpdateRfqUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<GenerateRfqRequirementsUseCase>(
    () => GenerateRfqRequirementsUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<CancelRfqUseCase>(
    () => CancelRfqUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<DeleteRfqUseCase>(
    () => DeleteRfqUseCase(sl<RetailerRfqRepository>()),
  );

  sl.registerLazySingleton<AcceptRfqQuotationUseCase>(
    () => AcceptRfqQuotationUseCase(sl<RetailerRfqRepository>()),
  );

  // =========================
  // RETAILER ORDER USE CASES
  // =========================
  sl.registerLazySingleton<GetRetailerOrdersUseCase>(
    () => GetRetailerOrdersUseCase(sl<RetailerOrderRepository>()),
  );

  sl.registerLazySingleton<GetRetailerOrderDetailsUseCase>(
    () => GetRetailerOrderDetailsUseCase(sl<RetailerOrderRepository>()),
  );

  sl.registerLazySingleton<CancelRetailerOrderUseCase>(
    () => CancelRetailerOrderUseCase(sl<RetailerOrderRepository>()),
  );

  sl.registerLazySingleton<ReorderRetailerOrderUseCase>(
    () => ReorderRetailerOrderUseCase(sl<RetailerOrderRepository>()),
  );

  // =========================
  // SUPPLIER RFQ USE CASES
  // =========================
  sl.registerLazySingleton<GetOpenSupplierRfqsUseCase>(
    () => GetOpenSupplierRfqsUseCase(sl<SupplierRfqRepository>()),
  );

  sl.registerLazySingleton<GetSupplierRfqDetailsUseCase>(
    () => GetSupplierRfqDetailsUseCase(sl<SupplierRfqRepository>()),
  );

  sl.registerLazySingleton<SubmitSupplierRfqQuotationUseCase>(
    () => SubmitSupplierRfqQuotationUseCase(sl<SupplierRfqRepository>()),
  );

  sl.registerLazySingleton<UpdateSupplierRfqQuotationUseCase>(
    () => UpdateSupplierRfqQuotationUseCase(sl<SupplierRfqRepository>()),
  );

  sl.registerLazySingleton<WithdrawSupplierRfqQuotationUseCase>(
    () => WithdrawSupplierRfqQuotationUseCase(sl<SupplierRfqRepository>()),
  );

  // =========================
  // AUTH USE CASES
  // =========================
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RetailerSignupUseCase>(
    () => RetailerSignupUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );

  // =========================
  // SUPPLIER PROFILE USE CASES
  // =========================
  sl.registerLazySingleton<CreateSupplierProfileUseCase>(
    () => CreateSupplierProfileUseCase(sl<SupplierProfileRepository>()),
  );

  sl.registerLazySingleton<GetSupplierProfileDisplayUseCase>(
    () => GetSupplierProfileDisplayUseCase(
      sl<SupplierProfileDisplayRepository>(),
    ),
  );

  // =========================
  // SUPPLIER CATEGORY / CATALOG USE CASES
  // =========================
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<GetSubCategoriesByCategoryUseCase>(
    () => GetSubCategoriesByCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<GetAllSubCategoriesUseCase>(
    () => GetAllSubCategoriesUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<UpdateCategoryStatusUseCase>(
    () => UpdateCategoryStatusUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<CreateSubCategoryUseCase>(
    () => CreateSubCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<UpdateSubCategoryUseCase>(
    () => UpdateSubCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<UpdateSubCategoryStatusUseCase>(
    () => UpdateSubCategoryStatusUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<DeleteSubCategoryUseCase>(
    () => DeleteSubCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  // =========================
  // SUPPLIER PRODUCT USE CASES
  // =========================
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<SearchProductsUseCase>(
    () => SearchProductsUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<ProductRepository>()),
  );

  // =========================
  // SUPPLIER EXCEL IMPORT USE CASES
  // =========================
  sl.registerLazySingleton<PickSupplierExcelFileUseCase>(
    () => PickSupplierExcelFileUseCase(sl<SupplierExcelImportRepository>()),
  );

  sl.registerLazySingleton<ParseSupplierExcelFileUseCase>(
    () => ParseSupplierExcelFileUseCase(sl<SupplierExcelImportRepository>()),
  );

  sl.registerLazySingleton<ValidateSupplierExcelRowsUseCase>(
    () => ValidateSupplierExcelRowsUseCase(),
  );

  sl.registerLazySingleton<ImportSupplierExcelProductsUseCase>(
    () => ImportSupplierExcelProductsUseCase(
      createCategoryUseCase: sl<CreateCategoryUseCase>(),
      createSubCategoryUseCase: sl<CreateSubCategoryUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      getSubCategoriesByCategoryUseCase:
          sl<GetSubCategoriesByCategoryUseCase>(),
      createBranchUseCase: sl<CreateBranchUseCase>(),
      getBranchesUseCase: sl<GetBranchesUseCase>(),
      createProductUseCase: sl<CreateProductUseCase>(),
      getProductsUseCase: sl<GetProductsUseCase>(),
      assignProductToBranchUseCase: sl<AssignProductToBranchUseCase>(),
      getInventoryByBranchUseCase: sl<GetInventoryByBranchUseCase>(),
      updateBranchStockUseCase: sl<UpdateBranchStockUseCase>(),
      createShippingMethodUseCase: sl<CreateShippingMethodUseCase>(),
      getShippingMethodsUseCase: sl<GetShippingMethodsUseCase>(),
      createTaxRuleUseCase: sl<CreateTaxRuleUseCase>(),
      updateTaxRuleUseCase: sl<UpdateTaxRuleUseCase>(),
      getTaxRulesUseCase: sl<GetTaxRulesUseCase>(),
      createCouponUseCase: sl<CreateCouponUseCase>(),
      getCouponsUseCase: sl<GetCouponsUseCase>(),
      shippingLocationApiService: sl<ShippingLocationApiService>(),
      createPromotionUseCase: sl<CreatePromotionUseCase>(),
      getPromotionsUseCase: sl<GetPromotionsUseCase>(),
      createBannerUseCase: sl<CreateBannerUseCase>(),
      getBannersUseCase: sl<GetBannersUseCase>(),
    ),
  );

  sl.registerLazySingleton<ClearSupplierExcelImportUseCase>(
    () => const ClearSupplierExcelImportUseCase(),
  );

  // =========================
  // SUPPLIER BRANCH USE CASES
  // =========================
  sl.registerLazySingleton<GetBranchesUseCase>(
    () => GetBranchesUseCase(sl<BranchRepository>()),
  );

  sl.registerLazySingleton<SearchBranchesUseCase>(
    () => SearchBranchesUseCase(sl<BranchRepository>()),
  );

  sl.registerLazySingleton<CreateBranchUseCase>(
    () => CreateBranchUseCase(sl<BranchRepository>()),
  );

  sl.registerLazySingleton<UpdateBranchUseCase>(
    () => UpdateBranchUseCase(sl<BranchRepository>()),
  );

  sl.registerLazySingleton<DeleteBranchUseCase>(
    () => DeleteBranchUseCase(sl<BranchRepository>()),
  );

  // =========================
  // SUPPLIER BRANCH INVENTORY USE CASES
  // =========================
  sl.registerLazySingleton<GetInventoryByBranchUseCase>(
    () => GetInventoryByBranchUseCase(sl<BranchInventoryRepository>()),
  );

  sl.registerLazySingleton<GetInventoryByProductUseCase>(
    () => GetInventoryByProductUseCase(sl<BranchInventoryRepository>()),
  );

  sl.registerLazySingleton<AssignProductToBranchUseCase>(
    () => AssignProductToBranchUseCase(sl<BranchInventoryRepository>()),
  );

  sl.registerLazySingleton<UpdateBranchStockUseCase>(
    () => UpdateBranchStockUseCase(sl<BranchInventoryRepository>()),
  );

  sl.registerLazySingleton<DeleteInventoryItemUseCase>(
    () => DeleteInventoryItemUseCase(sl<BranchInventoryRepository>()),
  );

  // =========================
  // SUPPLIER COUPON USE CASES
  // =========================
  sl.registerLazySingleton<GetCouponsUseCase>(
    () => GetCouponsUseCase(sl<CouponRepository>()),
  );

  sl.registerLazySingleton<CreateCouponUseCase>(
    () => CreateCouponUseCase(sl<CouponRepository>()),
  );

  sl.registerLazySingleton<UpdateCouponUseCase>(
    () => UpdateCouponUseCase(sl<CouponRepository>()),
  );

  sl.registerLazySingleton<DeleteCouponUseCase>(
    () => DeleteCouponUseCase(sl<CouponRepository>()),
  );

  // =========================
  // SUPPLIER PROMOTION USE CASES
  // =========================
  sl.registerLazySingleton<GetPromotionsUseCase>(
    () => GetPromotionsUseCase(sl<PromotionRepository>()),
  );

  sl.registerLazySingleton<CreatePromotionUseCase>(
    () => CreatePromotionUseCase(sl<PromotionRepository>()),
  );

  sl.registerLazySingleton<UpdatePromotionUseCase>(
    () => UpdatePromotionUseCase(sl<PromotionRepository>()),
  );

  sl.registerLazySingleton<DeletePromotionUseCase>(
    () => DeletePromotionUseCase(sl<PromotionRepository>()),
  );

  // =========================
  // SUPPLIER BANNER USE CASES
  // =========================
  sl.registerLazySingleton<GetBannersUseCase>(
    () => GetBannersUseCase(sl<BannerRepository>()),
  );

  sl.registerLazySingleton<CreateBannerUseCase>(
    () => CreateBannerUseCase(sl<BannerRepository>()),
  );

  sl.registerLazySingleton<UpdateBannerUseCase>(
    () => UpdateBannerUseCase(sl<BannerRepository>()),
  );

  sl.registerLazySingleton<DeleteBannerUseCase>(
    () => DeleteBannerUseCase(sl<BannerRepository>()),
  );

  // =========================
  // SUPPLIER SHIPPING METHOD USE CASES
  // =========================
  sl.registerLazySingleton<GetShippingMethodsUseCase>(
    () => GetShippingMethodsUseCase(sl<ShippingMethodRepository>()),
  );

  sl.registerLazySingleton<CreateShippingMethodUseCase>(
    () => CreateShippingMethodUseCase(sl<ShippingMethodRepository>()),
  );

  sl.registerLazySingleton<UpdateShippingMethodUseCase>(
    () => UpdateShippingMethodUseCase(sl<ShippingMethodRepository>()),
  );

  sl.registerLazySingleton<DeleteShippingMethodUseCase>(
    () => DeleteShippingMethodUseCase(sl<ShippingMethodRepository>()),
  );

  // =========================
  // SUPPLIER TAX RULE USE CASES
  // =========================
  sl.registerLazySingleton<GetTaxRulesUseCase>(
    () => GetTaxRulesUseCase(sl<TaxRuleRepository>()),
  );

  sl.registerLazySingleton<CreateTaxRuleUseCase>(
    () => CreateTaxRuleUseCase(sl<TaxRuleRepository>()),
  );

  sl.registerLazySingleton<UpdateTaxRuleUseCase>(
    () => UpdateTaxRuleUseCase(sl<TaxRuleRepository>()),
  );

  sl.registerLazySingleton<DeleteTaxRuleUseCase>(
    () => DeleteTaxRuleUseCase(sl<TaxRuleRepository>()),
  );

  sl.registerLazySingleton<PreviewTaxUseCase>(
    () => PreviewTaxUseCase(sl<TaxRuleRepository>()),
  );

  // =========================
  // SUPPLIER ORDER USE CASES
  // =========================
  sl.registerLazySingleton<GetSupplierOrdersUseCase>(
    () => GetSupplierOrdersUseCase(sl<SupplierOrderRepository>()),
  );

  sl.registerLazySingleton<GetSupplierOrderDetailsUseCase>(
    () => GetSupplierOrderDetailsUseCase(sl<SupplierOrderRepository>()),
  );

  sl.registerLazySingleton<UpdateSupplierOrderStatusUseCase>(
    () => UpdateSupplierOrderStatusUseCase(sl<SupplierOrderRepository>()),
  );

  sl.registerLazySingleton<GetSupplierOrderPaymentUseCase>(
    () => GetSupplierOrderPaymentUseCase(sl<SupplierPaymentRepository>()),
  );

  sl.registerLazySingleton<MarkSupplierCashPaymentPaidUseCase>(
    () => MarkSupplierCashPaymentPaidUseCase(sl<SupplierPaymentRepository>()),
  );

  // =========================
  // SUPPLIER DASHBOARD USE CASES
  // =========================
  sl.registerLazySingleton<GetSupplierLowStockAlertsUseCase>(
    () => GetSupplierLowStockAlertsUseCase(sl<SupplierDashboardRepository>()),
  );

  // =========================
  // CUBITS / BLOCS
  // =========================
  sl.registerLazySingleton<AppCurrencyCubit>(
    () => AppCurrencyCubit(
      getProjectCurrencyUseCase: sl<GetProjectCurrencyUseCase>(),
    ),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      retailerSignupUseCase: sl<RetailerSignupUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    ),
  );

  sl.registerFactory<SupplierProfileCubit>(
    () => SupplierProfileCubit(
      createSupplierProfileUseCase: sl<CreateSupplierProfileUseCase>(),
    ),
  );

  sl.registerFactory<SupplierProfileDisplayBloc>(
    () => SupplierProfileDisplayBloc(
      getSupplierProfileDisplayUseCase: sl<GetSupplierProfileDisplayUseCase>(),
    ),
  );
  sl.registerFactory<RetailerCheckoutCubit>(
    () => RetailerCheckoutCubit(apiService: sl<RetailerCheckoutApiService>()),
  );

  // =========================
  // SUPPLIER BLOCS
  // =========================
  sl.registerFactory<ProductListBloc>(
    () => ProductListBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      searchProductsUseCase: sl<SearchProductsUseCase>(),
      deleteProductUseCase: sl<DeleteProductUseCase>(),
    ),
  );

  sl.registerFactory<SupplierCatalogBloc>(
    () => SupplierCatalogBloc(
      getAllCategoriesUseCase: sl<GetAllCategoriesUseCase>(),
      getAllSubCategoriesUseCase: sl<GetAllSubCategoriesUseCase>(),
      createCategoryUseCase: sl<CreateCategoryUseCase>(),
      updateCategoryUseCase: sl<UpdateCategoryUseCase>(),
      updateCategoryStatusUseCase: sl<UpdateCategoryStatusUseCase>(),
      deleteCategoryUseCase: sl<DeleteCategoryUseCase>(),
      createSubCategoryUseCase: sl<CreateSubCategoryUseCase>(),
      updateSubCategoryUseCase: sl<UpdateSubCategoryUseCase>(),
      updateSubCategoryStatusUseCase: sl<UpdateSubCategoryStatusUseCase>(),
      deleteSubCategoryUseCase: sl<DeleteSubCategoryUseCase>(),
    ),
  );

  sl.registerFactory<BranchListBloc>(
    () => BranchListBloc(
      getBranchesUseCase: sl<GetBranchesUseCase>(),
      searchBranchesUseCase: sl<SearchBranchesUseCase>(),
      deleteBranchUseCase: sl<DeleteBranchUseCase>(),
    ),
  );

  sl.registerFactory<BranchInventoryBloc>(
    () => BranchInventoryBloc(
      getInventoryByBranchUseCase: sl<GetInventoryByBranchUseCase>(),
      getProductsUseCase: sl<GetProductsUseCase>(),
      assignProductToBranchUseCase: sl<AssignProductToBranchUseCase>(),
      updateBranchStockUseCase: sl<UpdateBranchStockUseCase>(),
      deleteInventoryItemUseCase: sl<DeleteInventoryItemUseCase>(),
    ),
  );

  sl.registerFactory<ProductBranchInventoryBloc>(
    () => ProductBranchInventoryBloc(
      getBranchesUseCase: sl<GetBranchesUseCase>(),
      getInventoryByProductUseCase: sl<GetInventoryByProductUseCase>(),
      assignProductToBranchUseCase: sl<AssignProductToBranchUseCase>(),
      updateBranchStockUseCase: sl<UpdateBranchStockUseCase>(),
      deleteInventoryItemUseCase: sl<DeleteInventoryItemUseCase>(),
    ),
  );

  sl.registerFactory<CouponsBloc>(
    () => CouponsBloc(
      getCouponsUseCase: sl<GetCouponsUseCase>(),
      createCouponUseCase: sl<CreateCouponUseCase>(),
      updateCouponUseCase: sl<UpdateCouponUseCase>(),
      deleteCouponUseCase: sl<DeleteCouponUseCase>(),
    ),
  );

  sl.registerFactory<PromotionsBloc>(
    () => PromotionsBloc(
      getPromotionsUseCase: sl<GetPromotionsUseCase>(),
      createPromotionUseCase: sl<CreatePromotionUseCase>(),
      updatePromotionUseCase: sl<UpdatePromotionUseCase>(),
      deletePromotionUseCase: sl<DeletePromotionUseCase>(),
    ),
  );

  sl.registerFactory<BannersBloc>(
    () => BannersBloc(
      getBannersUseCase: sl<GetBannersUseCase>(),
      createBannerUseCase: sl<CreateBannerUseCase>(),
      updateBannerUseCase: sl<UpdateBannerUseCase>(),
      deleteBannerUseCase: sl<DeleteBannerUseCase>(),
    ),
  );

  sl.registerFactory<ShippingMethodsBloc>(
    () => ShippingMethodsBloc(
      getShippingMethodsUseCase: sl<GetShippingMethodsUseCase>(),
      createShippingMethodUseCase: sl<CreateShippingMethodUseCase>(),
      updateShippingMethodUseCase: sl<UpdateShippingMethodUseCase>(),
      deleteShippingMethodUseCase: sl<DeleteShippingMethodUseCase>(),
    ),
  );

  sl.registerFactory<TaxRulesBloc>(
    () => TaxRulesBloc(
      getTaxRulesUseCase: sl<GetTaxRulesUseCase>(),
      createTaxRuleUseCase: sl<CreateTaxRuleUseCase>(),
      updateTaxRuleUseCase: sl<UpdateTaxRuleUseCase>(),
      deleteTaxRuleUseCase: sl<DeleteTaxRuleUseCase>(),
    ),
  );

  sl.registerFactory<SupplierExcelImportBloc>(
    () => SupplierExcelImportBloc(
      pickSupplierExcelFileUseCase: sl<PickSupplierExcelFileUseCase>(),
      parseSupplierExcelFileUseCase: sl<ParseSupplierExcelFileUseCase>(),
      validateSupplierExcelRowsUseCase: sl<ValidateSupplierExcelRowsUseCase>(),
      importSupplierExcelProductsUseCase:
          sl<ImportSupplierExcelProductsUseCase>(),
      clearSupplierExcelImportUseCase: sl<ClearSupplierExcelImportUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      getSubCategoriesByCategoryUseCase:
          sl<GetSubCategoriesByCategoryUseCase>(),
      getProductsUseCase: sl<GetProductsUseCase>(),
      getBranchesUseCase: sl<GetBranchesUseCase>(),
    ),
  );

  sl.registerFactory<SupplierOrdersBloc>(
    () => SupplierOrdersBloc(
      getSupplierOrdersUseCase: sl<GetSupplierOrdersUseCase>(),
    ),
  );

  sl.registerFactory<SupplierOrderDetailsBloc>(
    () => SupplierOrderDetailsBloc(
      getSupplierOrderDetailsUseCase: sl<GetSupplierOrderDetailsUseCase>(),
      updateSupplierOrderStatusUseCase: sl<UpdateSupplierOrderStatusUseCase>(),
      getSupplierOrderPaymentUseCase: sl<GetSupplierOrderPaymentUseCase>(),
      markSupplierCashPaymentPaidUseCase:
          sl<MarkSupplierCashPaymentPaidUseCase>(),
    ),
  );

  sl.registerFactory<SupplierDashboardBloc>(
    () => SupplierDashboardBloc(
      getSupplierOrdersUseCase: sl<GetSupplierOrdersUseCase>(),
      getSupplierLowStockAlertsUseCase: sl<GetSupplierLowStockAlertsUseCase>(),
      getSupplierProfileDisplayUseCase: sl<GetSupplierProfileDisplayUseCase>(),
    ),
  );

  // =========================
  // RETAILER CUBITS
  // =========================
  sl.registerFactory<RetailerHomeCubit>(
    () =>
        RetailerHomeCubit(retailerHomeRepository: sl<RetailerHomeRepository>()),
  );

  sl.registerFactory<RetailerCartCubit>(
    () => RetailerCartCubit(retailerCartService: sl<RetailerCartService>()),
  );

  sl.registerFactory<RetailerProfileCubit>(
    () => RetailerProfileCubit(
      retailerProfileRepository: sl<RetailerProfileRepository>(),
    ),
  );

  sl.registerFactory<RetailerOrdersCubit>(
    () => RetailerOrdersCubit(
      getRetailerOrdersUseCase: sl<GetRetailerOrdersUseCase>(),
      getRetailerOrderDetailsUseCase: sl<GetRetailerOrderDetailsUseCase>(),
      cancelRetailerOrderUseCase: sl<CancelRetailerOrderUseCase>(),
      reorderRetailerOrderUseCase: sl<ReorderRetailerOrderUseCase>(),
    ),
  );

  sl.registerFactory<RetailerRfqCubit>(
    () => RetailerRfqCubit(
      getMyRfqsUseCase: sl<GetMyRfqsUseCase>(),
      getRfqDetailsUseCase: sl<GetRfqDetailsUseCase>(),
      createRfqUseCase: sl<CreateRfqUseCase>(),
      updateRfqUseCase: sl<UpdateRfqUseCase>(),
      cancelRfqUseCase: sl<CancelRfqUseCase>(),
      deleteRfqUseCase: sl<DeleteRfqUseCase>(),
      acceptRfqQuotationUseCase: sl<AcceptRfqQuotationUseCase>(),
      generateRfqRequirementsUseCase: sl<GenerateRfqRequirementsUseCase>(),
    ),
  );

  sl.registerFactory<SupplierRfqCubit>(
    () => SupplierRfqCubit(
      getOpenSupplierRfqsUseCase: sl<GetOpenSupplierRfqsUseCase>(),
      getSupplierRfqDetailsUseCase: sl<GetSupplierRfqDetailsUseCase>(),
      submitSupplierRfqQuotationUseCase:
          sl<SubmitSupplierRfqQuotationUseCase>(),
      updateSupplierRfqQuotationUseCase:
          sl<UpdateSupplierRfqQuotationUseCase>(),
      withdrawSupplierRfqQuotationUseCase:
          sl<WithdrawSupplierRfqQuotationUseCase>(),
    ),
  );

  sl.registerFactory<RetailerProductAiCubit>(
    () => RetailerProductAiCubit(repository: sl<RetailerProductAiRepository>()),
  );

  // =========================
  // NOTIFICATIONS (shared notify library)
  // =========================
  sl.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationApiService>()),
  );

  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<GetUnreadCountUseCase>(
    () => GetUnreadCountUseCase(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<MarkNotificationReadUseCase>(
    () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
  );

  sl.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      getUnreadCountUseCase: sl<GetUnreadCountUseCase>(),
      markNotificationReadUseCase: sl<MarkNotificationReadUseCase>(),
      authService: sl<AuthService>(),
    ),
  );

  // =========================
  // SUPPLIER LICENSING
  // =========================
  sl.registerLazySingleton<LicensingApiService>(
    () => LicensingApiService(
      sl<ApiClient>(instanceName: 'centralApiClient'),
    ),
  );

  sl.registerLazySingleton<ILicensingRepository>(
    () => LicensingRepositoryImpl(sl<LicensingApiService>()),
  );

  sl.registerLazySingleton<GetCurrentLicensePlan>(
    () => GetCurrentLicensePlan(sl<ILicensingRepository>()),
  );
  sl.registerLazySingleton<RefreshOwnerSubscription>(
    () => RefreshOwnerSubscription(sl<ILicensingRepository>()),
  );
  sl.registerLazySingleton<GetAvailableUpgradePlans>(
    () => GetAvailableUpgradePlans(sl<ILicensingRepository>()),
  );
  sl.registerLazySingleton<GetAvailablePaymentMethods>(
    () => GetAvailablePaymentMethods(sl<ILicensingRepository>()),
  );
  sl.registerLazySingleton<InitiateUpgradePayment>(
    () => InitiateUpgradePayment(sl<ILicensingRepository>()),
  );
  sl.registerLazySingleton<ConfirmUpgradePayment>(
    () => ConfirmUpgradePayment(sl<ILicensingRepository>()),
  );

  sl.registerFactory<SupplierSubscriptionCubit>(
    () => SupplierSubscriptionCubit(
      getCurrentLicensePlanUc: sl<GetCurrentLicensePlan>(),
    ),
  );

  sl.registerFactory<UpgradeFlowBloc>(
    () => UpgradeFlowBloc(
      getPlansUc: sl<GetAvailableUpgradePlans>(),
      getPaymentMethodsUc: sl<GetAvailablePaymentMethods>(),
      initiatePaymentUc: sl<InitiateUpgradePayment>(),
      confirmPaymentUc: sl<ConfirmUpgradePayment>(),
      refreshSubscriptionUc: sl<RefreshOwnerSubscription>(),
    ),
  );
}

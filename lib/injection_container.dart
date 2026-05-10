import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'core/storage/theme_storage.dart';
import 'core/storage/locale_storage.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/runtime_theme_service.dart';

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

import 'features/dashboard/data/services/retailer_cart_service.dart';
import 'features/dashboard/presentation/cubit/retailer_cart_cubit.dart';

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
import 'features/supplier/shipping/domain/repositories/shipping_method_repository.dart';
import 'features/supplier/shipping/domain/usecases/create_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/delete_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/get_shipping_methods_usecase.dart';
import 'features/supplier/shipping/domain/usecases/update_shipping_method_usecase.dart';
import 'features/supplier/shipping/presentation/bloc/shipping_methods_bloc.dart';

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
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<AuthStorage>(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
    instanceName: 'centralApiClient',
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<AuthStorage>(),
      baseUrl: AppConfig.projectApiBaseUrl,
    ),
    instanceName: 'projectApiClient',
  );

  // =========================
  // THEME / LOCALE
  // =========================
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<ThemeStorage>()),
  );

  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<LocaleStorage>()),
  );

  sl.registerLazySingleton<RuntimeThemeService>(
    () => RuntimeThemeService(),
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

  sl.registerLazySingleton<RetailerHomeService>(
    () => RetailerHomeService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<RetailerCartService>(
    () => RetailerCartService(
      projectApiClient: sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierProfileService>(
    () => SupplierProfileService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
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
    () => BranchApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<ProductApiService>(
    () => ProductApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
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
    () => CouponApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<PromotionApiService>(
    () => PromotionApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<BannerApiService>(
    () => BannerApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
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

  sl.registerLazySingleton<SupplierOrderApiService>(
    () => SupplierOrderApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierDashboardApiService>(
    () => SupplierDashboardApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  // =========================
  // REPOSITORIES
  // =========================
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

  sl.registerLazySingleton<SupplierCategoryRepository>(
    () => SupplierCategoryRepositoryImpl(
      apiService: sl<SupplierCategoryApiService>(),
    ),
  );

  sl.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImpl(
      apiService: sl<BranchApiService>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      apiService: sl<ProductApiService>(),
    ),
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
    () => CouponRepositoryImpl(
      apiService: sl<CouponApiService>(),
    ),
  );

  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(
      apiService: sl<PromotionApiService>(),
    ),
  );

  sl.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(
      apiService: sl<BannerApiService>(),
    ),
  );

  sl.registerLazySingleton<ShippingMethodRepository>(
    () => ShippingMethodRepositoryImpl(
      apiService: sl<ShippingMethodApiService>(),
    ),
  );

  sl.registerLazySingleton<SupplierOrderRepository>(
    () => SupplierOrderRepositoryImpl(
      apiService: sl<SupplierOrderApiService>(),
    ),
  );

  sl.registerLazySingleton<SupplierDashboardRepository>(
    () => SupplierDashboardRepositoryImpl(
      apiService: sl<SupplierDashboardApiService>(),
    ),
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
    () => GetSubCategoriesByCategoryUseCase(
      sl<SupplierCategoryRepository>(),
    ),
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
      createProductUseCase: sl<CreateProductUseCase>(),
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

  // =========================
  // SUPPLIER DASHBOARD USE CASES
  // =========================
  sl.registerLazySingleton<GetSupplierLowStockAlertsUseCase>(
    () => GetSupplierLowStockAlertsUseCase(
      sl<SupplierDashboardRepository>(),
    ),
  );

  // =========================
  // CUBITS / BLOCS
  // =========================
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
      getSupplierProfileDisplayUseCase:
          sl<GetSupplierProfileDisplayUseCase>(),
    ),
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
      updateSupplierOrderStatusUseCase:
          sl<UpdateSupplierOrderStatusUseCase>(),
    ),
  );

  sl.registerFactory<SupplierDashboardBloc>(
    () => SupplierDashboardBloc(
      getSupplierOrdersUseCase: sl<GetSupplierOrdersUseCase>(),
      getSupplierLowStockAlertsUseCase:
          sl<GetSupplierLowStockAlertsUseCase>(),
    ),
  );

  // =========================
  // RETAILER CUBITS
  // =========================
  sl.registerFactory<RetailerHomeCubit>(
    () => RetailerHomeCubit(
      retailerHomeRepository: sl<RetailerHomeRepository>(),
    ),
  );

  sl.registerFactory<RetailerCartCubit>(
    () => RetailerCartCubit(
      retailerCartService: sl<RetailerCartService>(),
    ),
  );

  sl.registerFactory<RetailerProfileCubit>(
    () => RetailerProfileCubit(
      retailerProfileRepository: sl<RetailerProfileRepository>(),
    ),
  );
}
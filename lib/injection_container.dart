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
// SUPPLIER CATEGORIES
// =========================
import 'features/supplier/categories/data/repositories/supplier_category_repository_impl.dart';
import 'features/supplier/categories/data/services/supplier_category_api_service.dart';
import 'features/supplier/categories/domain/repositories/supplier_category_repository.dart';

import 'features/supplier/categories/domain/usecases/get_categories_usecase.dart';
import 'features/supplier/categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/create_category_usecase.dart';
import 'features/supplier/categories/domain/usecases/create_subcategory_usecase.dart';

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
// SUPPLIER ORDERS
// =========================
import 'features/supplier/orders/data/repositories/supplier_order_repository_impl.dart';
import 'features/supplier/orders/data/services/supplier_order_api_service.dart';
import 'features/supplier/orders/domain/repositories/supplier_order_repository.dart';
import 'features/supplier/orders/domain/usecases/get_supplier_orders_usecase.dart';
import 'features/supplier/orders/domain/usecases/get_supplier_order_details_usecase.dart';
import 'features/supplier/orders/domain/usecases/update_supplier_order_status_usecase.dart';

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

  // Build4All central backend client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<AuthStorage>(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
    instanceName: 'centralApiClient',
  );

  // Wholesale project backend client
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

  sl.registerLazySingleton<SupplierProfileService>(
    () => SupplierProfileService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
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

  sl.registerLazySingleton<BranchInventoryApiService>(
    () => BranchInventoryApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<SupplierOrderApiService>(
    () => SupplierOrderApiService(
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

  sl.registerLazySingleton<BranchInventoryRepository>(
    () => BranchInventoryRepositoryImpl(
      apiService: sl<BranchInventoryApiService>(),
    ),
  );

  sl.registerLazySingleton<SupplierOrderRepository>(
    () => SupplierOrderRepositoryImpl(
      apiService: sl<SupplierOrderApiService>(),
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

  // =========================
  // SUPPLIER CATEGORY USE CASES
  // =========================

  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<GetSubCategoriesByCategoryUseCase>(
    () => GetSubCategoriesByCategoryUseCase(
      sl<SupplierCategoryRepository>(),
    ),
  );

  sl.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(sl<SupplierCategoryRepository>()),
  );

  sl.registerLazySingleton<CreateSubCategoryUseCase>(
    () => CreateSubCategoryUseCase(sl<SupplierCategoryRepository>()),
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
  // CUBITS
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
}
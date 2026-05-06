import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'core/storage/theme_storage.dart';
import 'core/storage/locale_storage.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/runtime_theme_service.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/retailer_signup_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

import 'features/supplier_profile/data/repositories/supplier_profile_repository_impl.dart';
import 'features/supplier_profile/data/services/supplier_profile_service.dart';
import 'features/supplier_profile/domain/repositories/supplier_profile_repository.dart';
import 'features/supplier_profile/domain/usecases/create_supplier_profile_usecase.dart';
import 'features/supplier_profile/presentation/bloc/supplier_profile_cubit.dart';

import 'features/supplier/categories/data/repositories/supplier_category_repository_impl.dart';
import 'features/supplier/categories/data/services/supplier_category_api_service.dart';
import 'features/supplier/categories/domain/repositories/supplier_category_repository.dart';

import 'features/supplier/branches/data/repositories/branch_repository_impl.dart';
import 'features/supplier/branches/data/repositories/branch_inventory_repository_impl.dart';
import 'features/supplier/branches/data/services/branch_api_service.dart';
import 'features/supplier/branches/data/services/branch_inventory_api_service.dart';
import 'features/supplier/branches/domain/repositories/branch_repository.dart';
import 'features/supplier/branches/domain/repositories/branch_inventory_repository.dart';

import 'features/supplier/products/data/repositories/product_repository_impl.dart';
import 'features/supplier/products/data/services/product_api_service.dart';
import 'features/supplier/products/domain/repositories/product_repository.dart';

import 'features/supplier/coupons/data/services/coupon_api_service.dart';
import 'features/supplier/coupons/data/repositories/coupon_repository_impl.dart';
import 'features/supplier/coupons/domain/repositories/coupon_repository.dart';
import 'features/supplier/coupons/domain/usecases/create_coupon_usecase.dart';
import 'features/supplier/coupons/domain/usecases/delete_coupon_usecase.dart';
import 'features/supplier/coupons/domain/usecases/get_coupons_usecase.dart';
import 'features/supplier/coupons/domain/usecases/update_coupon_usecase.dart';
import 'features/supplier/coupons/presentation/bloc/coupons_bloc.dart';

import 'features/supplier/promotions/data/services/promotion_api_service.dart';
import 'features/supplier/promotions/data/repositories/promotion_repository_impl.dart';
import 'features/supplier/promotions/domain/repositories/promotion_repository.dart';
import 'features/supplier/promotions/domain/usecases/create_promotion_usecase.dart';
import 'features/supplier/promotions/domain/usecases/delete_promotion_usecase.dart';
import 'features/supplier/promotions/domain/usecases/get_promotions_usecase.dart';
import 'features/supplier/promotions/domain/usecases/update_promotion_usecase.dart';
import 'features/supplier/promotions/presentation/bloc/promotions_bloc.dart';

import 'features/supplier/banners/data/services/banner_api_service.dart';
import 'features/supplier/banners/data/services/banner_image_upload_service.dart';
import 'features/supplier/banners/data/repositories/banner_repository_impl.dart';
import 'features/supplier/banners/domain/repositories/banner_repository.dart';
import 'features/supplier/banners/domain/usecases/create_banner_usecase.dart';
import 'features/supplier/banners/domain/usecases/delete_banner_usecase.dart';
import 'features/supplier/banners/domain/usecases/get_banners_usecase.dart';
import 'features/supplier/banners/domain/usecases/update_banner_usecase.dart';
import 'features/supplier/banners/presentation/bloc/banners_bloc.dart';

import 'features/supplier/shipping/data/repositories/shipping_method_repository_impl.dart';
import 'features/supplier/shipping/data/services/shipping_method_api_service.dart';
import 'features/supplier/shipping/domain/repositories/shipping_method_repository.dart';
import 'features/supplier/shipping/domain/usecases/create_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/delete_shipping_method_usecase.dart';
import 'features/supplier/shipping/domain/usecases/get_shipping_methods_usecase.dart';
import 'features/supplier/shipping/domain/usecases/update_shipping_method_usecase.dart';
import 'features/supplier/shipping/presentation/bloc/shipping_methods_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<AuthStorage>(() => AuthStorage());
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage());
  sl.registerLazySingleton<LocaleStorage>(() => LocaleStorage());

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

  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<ThemeStorage>()),
  );

  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<LocaleStorage>()),
  );

  sl.registerLazySingleton<RuntimeThemeService>(
    () => RuntimeThemeService(),
  );

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

  sl.registerLazySingleton<BranchInventoryApiService>(
    () => BranchInventoryApiService(
      sl<ApiClient>(instanceName: 'projectApiClient'),
    ),
  );

  sl.registerLazySingleton<ProductApiService>(
    () => ProductApiService(
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

  sl.registerLazySingleton<BranchInventoryRepository>(
    () => BranchInventoryRepositoryImpl(
      apiService: sl<BranchInventoryApiService>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      apiService: sl<ProductApiService>(),
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

  sl.registerLazySingleton<CreateSupplierProfileUseCase>(
    () => CreateSupplierProfileUseCase(sl<SupplierProfileRepository>()),
  );

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
}
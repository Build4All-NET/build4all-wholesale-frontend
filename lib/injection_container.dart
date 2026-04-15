import 'package:get_it/get_it.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'core/storage/theme_storage.dart';
import 'core/storage/locale_storage.dart';

import 'core/theme/theme_cubit.dart';
import 'core/theme/locale_cubit.dart';

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
import 'core/theme/runtime_theme_service.dart';


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

  // =========================
  // USE CASES
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

  sl.registerLazySingleton<CreateSupplierProfileUseCase>(
    () => CreateSupplierProfileUseCase(sl<SupplierProfileRepository>()),
  );
  sl.registerLazySingleton<RuntimeThemeService>(
  () => RuntimeThemeService(),
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
}

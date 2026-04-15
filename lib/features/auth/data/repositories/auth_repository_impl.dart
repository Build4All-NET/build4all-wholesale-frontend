import '../../../../core/config/app_config.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/api_response_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/forgot_password_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/admin_login_request_model.dart';
import '../models/build4all_supplier_sync_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/retailer_signup_request_model.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final AuthStorage authStorage;

  AuthRepositoryImpl({
    required this.authService,
    required this.authStorage,
  });

  /// Unified login flow:
  /// 1) Try Build4All admin/owner login first
  /// 2) If OWNER -> sync to wholesale backend
  /// 3) Then local wholesale login to get project JWT
  /// 4) If central admin login fails -> fallback to local retailer login
  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final ownerProjectId = int.tryParse(AppConfig.ownerProjectLinkId);

    try {
      final adminLoginResponse = await authService.adminLoginFront(
        AdminLoginRequestModel(
          usernameOrEmail: email,
          password: password,
          ownerProjectId: ownerProjectId,
        ),
      );

      final role = adminLoginResponse.role.toUpperCase();

      if (role == 'OWNER') {
        final admin = adminLoginResponse.admin ?? {};

        final firstName = admin['firstName']?.toString().trim() ?? '';
        final lastName = admin['lastName']?.toString().trim() ?? '';
        final fullName = '$firstName $lastName'.trim().isEmpty
            ? email
            : '$firstName $lastName'.trim();

        await authService.syncSupplierFromBuild4All(
          Build4AllSupplierSyncRequestModel(
            fullName: fullName,
            email: admin['email']?.toString() ?? email,
            password: password,
          ),
        );

        final projectLoginResponse = await authService.login(
          LoginRequestModel(
            email: admin['email']?.toString() ?? email,
            password: password,
          ),
        );

        if (projectLoginResponse.token != null &&
            projectLoginResponse.token!.isNotEmpty) {
          await authStorage.saveSession(
            token: projectLoginResponse.token!,
            userId: projectLoginResponse.userId,
            role: projectLoginResponse.role,
            profileCompleted: projectLoginResponse.profileCompleted,
          );
        }

        return projectLoginResponse;
      }

      if (role == 'SUPER_ADMIN') {
        throw AppException(
          'SUPER_ADMIN login is not supported inside the wholesale mobile app.',
        );
      }

      throw AppException('Access denied for this role');
    } catch (_) {
      final response = await authService.login(
        LoginRequestModel(
          email: email,
          password: password,
        ),
      );

      if (response.token != null && response.token!.isNotEmpty) {
        await authStorage.saveSession(
          token: response.token!,
          userId: response.userId,
          role: response.role,
          profileCompleted: response.profileCompleted,
        );
      }

      return response;
    }
  }

  @override
  Future<ApiResponseEntity> retailerSignup({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    required String storeAddress,
    required String city,
    required String businessType,
  }) async {
    final response = await authService.retailerSignup(
      RetailerSignupRequestModel(
        fullName: fullName,
        storeName: storeName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        storeAddress: storeAddress,
        city: city,
        businessType: businessType,
      ),
    );

    return response;
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    return await authService.getCurrentUser();
  }

  @override
  Future<ForgotPasswordResponseEntity> forgotPassword({
    required String email,
  }) async {
    final response = await authService.forgotPassword(
      ForgotPasswordRequestModel(email: email),
    );

    return response;
  }

  @override
  Future<ApiResponseEntity> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await authService.resetPassword(
      ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );

    return response;
  }
}

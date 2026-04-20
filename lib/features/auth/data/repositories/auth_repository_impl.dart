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

  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final ownerProjectId = int.tryParse(AppConfig.ownerProjectLinkId);

    // 1) Try local wholesale login first
    try {
      final localLogin = await authService.login(
        LoginRequestModel(
          email: email,
          password: password,
        ),
      );

      if (localLogin.token != null && localLogin.token!.isNotEmpty) {
        await authStorage.saveSession(
          token: localLogin.token!,
          userId: localLogin.userId,
          role: localLogin.role,
          profileCompleted: localLogin.profileCompleted,
        );
      }

      return localLogin;
    } on AppException {
      // continue to Build4All supplier flow
    } catch (_) {
      // continue to Build4All supplier flow
    }

    // 2) If local login fails, try OWNER/SUPPLIER through Build4All admin login
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
        final firstName = admin['firstName']?.toString() ?? '';
        final lastName = admin['lastName']?.toString() ?? '';
        final username = admin['username']?.toString() ?? email;
        final adminEmail = admin['email']?.toString() ?? email;

        await authService.syncSupplierFromBuild4All(
          Build4AllSupplierSyncRequestModel(
            build4allUserId: admin['id'] is int
                ? admin['id'] as int
                : int.tryParse(admin['id']?.toString() ?? ''),
            ownerProjectLinkId: ownerProjectId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            fullName: ('$firstName $lastName').trim(),
            email: adminEmail,
            password: password,
          ),
        );

        final localLogin = await authService.login(
          LoginRequestModel(
            email: adminEmail,
            password: password,
          ),
        );

        if (localLogin.token != null && localLogin.token!.isNotEmpty) {
          await authStorage.saveSession(
            token: localLogin.token!,
            userId: localLogin.userId,
            role: localLogin.role,
            profileCompleted: localLogin.profileCompleted,
          );
        }

        return localLogin;
      }

      if (role == 'SUPER_ADMIN') {
        throw AppException(
          'SUPER_ADMIN login is not supported inside the wholesale mobile app.',
        );
      }

      throw AppException('This account is not allowed in the wholesale app.');
    } on AppException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw AppException('Login failed. Check your credentials.');
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
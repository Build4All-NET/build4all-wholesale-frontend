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

    // 1) try OWNER / SUPPLIER through Build4All admin login
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
    } catch (_) {
      // ignore and continue to retailer flow
    }

    // 2) try Build4All retailer/user login
    try {
      final userLogin = await authService.build4AllUserLogin(
        email: email,
        password: password,
      );

      final user = Map<String, dynamic>.from(userLogin['user'] as Map);
      final build4allUserId = user['id'] is int
          ? user['id'] as int
          : int.parse(user['id'].toString());

      final username = user['username']?.toString() ?? email;
      final firstName = user['firstName']?.toString() ?? '';
      final lastName = user['lastName']?.toString() ?? '';
      final userEmail = user['email']?.toString() ?? email;

      await authService.syncRetailerFromBuild4All(
        build4allUserId: build4allUserId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: userEmail,
        password: password,
      );

      final localLogin = await authService.login(
        LoginRequestModel(
          email: userEmail,
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
    } catch (e) {
      throw AppException(
        e is AppException ? e.message : 'Login failed. Check your credentials.',
      );
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
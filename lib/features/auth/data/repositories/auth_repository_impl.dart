import '../../../../core/config/app_config.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/api_response_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/forgot_password_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/admin_login_request_model.dart';
import '../models/build4all_supplier_sync_request_model.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final AuthStorage authStorage;

  AuthRepositoryImpl({required this.authService, required this.authStorage});

  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final ownerProjectId = int.tryParse(AppConfig.ownerProjectLinkId);

    if (ownerProjectId == null) {
      throw AppException('OWNER_PROJECT_LINK_ID is missing or invalid.');
    }

    try {
      final userLoginResponse = await authService.build4AllUserLogin(
        email: email,
        password: password,
      );

      final wasDeleted = userLoginResponse['wasDeleted'] == true;

      if (wasDeleted) {
        final message = userLoginResponse['message']?.toString().trim();

        throw AppException(
          message == null || message.isEmpty
              ? 'This account was deleted. Confirm reactivation.'
              : message,
        );
      }

      final token = userLoginResponse['token']?.toString() ?? '';
      final user = Map<String, dynamic>.from(userLoginResponse['user'] as Map);

      final build4allUserId = user['id'] is int
          ? user['id'] as int
          : int.parse(user['id'].toString());

      final username = user['username']?.toString() ?? email;
      final firstName = user['firstName']?.toString() ?? '';
      final lastName = user['lastName']?.toString() ?? '';
      final userEmail = user['email']?.toString() ?? email;
      final fullName = ('$firstName $lastName').trim();

      await authStorage.saveSession(
        token: token,
        build4allUserId: build4allUserId,
        ownerProjectLinkId: ownerProjectId,
        role: 'RETAILER',
        profileCompleted: false,
        email: userEmail,
        fullName: fullName,
      );

      await authService.syncRetailerFromBuild4All(
        build4allUserId: build4allUserId,
        ownerProjectLinkId: ownerProjectId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: userEmail,
      );

      final me = await authService.getWholesaleMe();

      await authStorage.saveSession(
        token: token,
        build4allUserId: build4allUserId,
        ownerProjectLinkId: ownerProjectId,
        role: 'RETAILER',
        profileCompleted: me.profileCompleted,
        email: userEmail,
        fullName: fullName,
      );

      return AuthUserEntity(
        userId: build4allUserId,
        fullName: fullName,
        email: userEmail,
        role: 'RETAILER',
        provider: 'BUILD4ALL',
        profileCompleted: me.profileCompleted,
        token: token,
        message: 'Login successful',
      );
    } catch (_) {}

    final adminLoginResponse = await authService.adminLoginFront(
      AdminLoginRequestModel(
        usernameOrEmail: email,
        password: password,
        ownerProjectId: ownerProjectId,
      ),
    );

    final role = adminLoginResponse.role.toUpperCase();
    if (role != 'OWNER') {
      throw AppException('Only OWNER can use Supplier Manager.');
    }

    final admin = adminLoginResponse.admin ?? {};
    final build4allUserId = admin['id'] is int
        ? admin['id'] as int
        : int.parse(admin['id'].toString());

    final firstName = admin['firstName']?.toString() ?? '';
    final lastName = admin['lastName']?.toString() ?? '';
    final username = admin['username']?.toString() ?? email;
    final adminEmail = admin['email']?.toString() ?? email;
    final fullName = ('$firstName $lastName').trim();
    final token = adminLoginResponse.token;

    await authStorage.saveSession(
      token: token,
      build4allUserId: build4allUserId,
      ownerProjectLinkId: ownerProjectId,
      role: 'SUPPLIER',
      profileCompleted: false,
      email: adminEmail,
      fullName: fullName,
    );

    await authService.syncSupplierFromBuild4All(
      Build4AllSupplierSyncRequestModel(
        build4allUserId: build4allUserId,
        ownerProjectLinkId: ownerProjectId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        email: adminEmail,
        password: '',
      ),
    );

    final me = await authService.getWholesaleMe();

    await authStorage.saveSession(
      token: token,
      build4allUserId: build4allUserId,
      ownerProjectLinkId: ownerProjectId,
      role: 'SUPPLIER',
      profileCompleted: me.profileCompleted,
      email: adminEmail,
      fullName: fullName,
    );

    return AuthUserEntity(
      userId: build4allUserId,
      fullName: fullName,
      email: adminEmail,
      role: 'SUPPLIER',
      provider: 'BUILD4ALL',
      profileCompleted: me.profileCompleted,
      token: token,
      message: 'Login successful',
    );
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
  }) {
    throw AppException(
      'Retailer signup must use the Build4All verification flow only.',
    );
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    final me = await authService.getWholesaleMe();
    final id = await authStorage.getBuild4allUserId() ?? 0;
    final email = await authStorage.getEmail() ?? '';
    final fullName = await authStorage.getFullName() ?? '';

    return AuthUserEntity(
      userId: id,
      fullName: fullName,
      email: email,
      role: me.role,
      provider: 'BUILD4ALL',
      profileCompleted: me.profileCompleted,
      token: null,
      message: me.message,
    );
  }

  @override
  Future<ForgotPasswordResponseEntity> forgotPassword({
    required String email,
  }) async {
    return await authService.forgotPassword(email: email);
  }

  @override
  Future<ApiResponseEntity> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.trim() != confirmPassword.trim()) {
      throw AppException('Passwords do not match.');
    }

    final parts = resetToken.split('|||');
    if (parts.length != 2) {
      throw AppException('Invalid reset session. Please request a new code.');
    }

    final email = parts[0];
    final code = parts[1];

    return await authService.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    await authStorage.clearSession();
  }
}

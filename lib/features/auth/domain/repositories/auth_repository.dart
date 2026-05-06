import '../entities/api_response_entity.dart';
import '../entities/auth_user_entity.dart';
import '../entities/forgot_password_response_entity.dart';
import '../entities/login_account_type.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> login({
    required String email,
    required String password,
    LoginAccountType? preferredAccountType,
  });

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
  });

  Future<AuthUserEntity> getCurrentUser();

  Future<ForgotPasswordResponseEntity> forgotPassword({required String email});

  Future<ApiResponseEntity> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();
}

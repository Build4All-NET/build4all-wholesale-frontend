import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/api_response_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/login_request_model.dart';
import '../models/retailer_signup_request_model.dart';
import '../services/auth_service.dart';
import '../../domain/entities/forgot_password_response_entity.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';
class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final AuthStorage authStorage;


  AuthRepositoryImpl({
    required this.authService,
    required this.authStorage,
  });


  // LOGIN 
  @override
  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await authService.login(
      LoginRequestModel(
        email: email,
        password: password,
      ),
    );


    //  save session (token + user info)
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


  //  SIGNUP 
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


  // CURRENT USER 
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

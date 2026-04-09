import 'package:equatable/equatable.dart';
import '../../domain/entities/api_response_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/forgot_password_response_entity.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final AuthUserEntity? user;
  final ApiResponseEntity? signupResponse;
  final ForgotPasswordResponseEntity? forgotPasswordResponse;
  final ApiResponseEntity? resetPasswordResponse;
  final String? errorMessage;
  final bool loginSuccess;
  final bool signupSuccess;
  final bool forgotPasswordSuccess;
  final bool resetPasswordSuccess;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.signupResponse,
    this.forgotPasswordResponse,
    this.resetPasswordResponse,
    this.errorMessage,
    this.loginSuccess = false,
    this.signupSuccess = false,
    this.forgotPasswordSuccess = false,
    this.resetPasswordSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthUserEntity? user,
    ApiResponseEntity? signupResponse,
    ForgotPasswordResponseEntity? forgotPasswordResponse,
    ApiResponseEntity? resetPasswordResponse,
    String? errorMessage,
    bool? loginSuccess,
    bool? signupSuccess,
    bool? forgotPasswordSuccess,
    bool? resetPasswordSuccess,
    bool clearError = false,
    bool clearUser = false,
    bool clearSignupResponse = false,
    bool clearForgotPasswordResponse = false,
    bool clearResetPasswordResponse = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      signupResponse:
          clearSignupResponse ? null : (signupResponse ?? this.signupResponse),
      forgotPasswordResponse: clearForgotPasswordResponse
          ? null
          : (forgotPasswordResponse ?? this.forgotPasswordResponse),
      resetPasswordResponse: clearResetPasswordResponse
          ? null
          : (resetPasswordResponse ?? this.resetPasswordResponse),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loginSuccess: loginSuccess ?? this.loginSuccess,
      signupSuccess: signupSuccess ?? this.signupSuccess,
      forgotPasswordSuccess:
          forgotPasswordSuccess ?? this.forgotPasswordSuccess,
      resetPasswordSuccess:
          resetPasswordSuccess ?? this.resetPasswordSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        user,
        signupResponse,
        forgotPasswordResponse,
        resetPasswordResponse,
        errorMessage,
        loginSuccess,
        signupSuccess,
        forgotPasswordSuccess,
        resetPasswordSuccess,
      ];
}

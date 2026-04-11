import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/retailer_signup_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RetailerSignupUseCase retailerSignupUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.retailerSignupUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        loginSuccess: false,
        clearError: true,
      ),
    );

    try {
      final user = await loginUseCase(
        email: email,
        password: password,
      );

      emit(
        state.copyWith(
          isLoading: false,
          user: user,
          loginSuccess: true,
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          loginSuccess: false,
        ),
      );
    }
  }

  Future<void> retailerSignup({
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
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        signupSuccess: false,
        clearError: true,
      ),
    );

    try {
      final response = await retailerSignupUseCase(
        fullName: fullName,
        storeName: storeName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        storeAddress: storeAddress,
        city: city,
        businessType: businessType,
      );

      emit(
        state.copyWith(
          isLoading: false,
          signupResponse: response,
          signupSuccess: true,
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          signupSuccess: false,
        ),
      );
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        forgotPasswordSuccess: false,
        clearError: true,
      ),
    );

    try {
      final response = await forgotPasswordUseCase(email: email);

      emit(
        state.copyWith(
          isLoading: false,
          forgotPasswordResponse: response,
          forgotPasswordSuccess: true,
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          forgotPasswordSuccess: false,
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        resetPasswordSuccess: false,
        clearError: true,
      ),
    );

    try {
      final response = await resetPasswordUseCase(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      emit(
        state.copyWith(
          isLoading: false,
          resetPasswordResponse: response,
          resetPasswordSuccess: true,
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          resetPasswordSuccess: false,
        ),
      );
    }
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearError: true,
        clearSignupResponse: true,
        clearForgotPasswordResponse: true,
        clearResetPasswordResponse: true,
        loginSuccess: false,
        signupSuccess: false,
        forgotPasswordSuccess: false,
        resetPasswordSuccess: false,
      ),
    );
  }
}

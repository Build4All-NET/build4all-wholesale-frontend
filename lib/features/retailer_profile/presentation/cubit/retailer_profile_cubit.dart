import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/retailer_profile_model.dart';
import '../../domain/repositories/retailer_profile_repository.dart';
import 'retailer_profile_state.dart';

class RetailerProfileCubit extends Cubit<RetailerProfileState> {
  final RetailerProfileRepository retailerProfileRepository;

  RetailerProfileCubit({required this.retailerProfileRepository})
    : super(const RetailerProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final profile = await retailerProfileRepository.getProfile();

      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<AccountProfileUpdateResult?> updateAccountInfo({
    required String username,
    required String firstName,
    required String lastName,
    String? changedEmail,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    try {
      final result = await retailerProfileRepository.updateAccountInfo(
        username: username,
        firstName: firstName,
        lastName: lastName,
        changedEmail: changedEmail,
      );

      emit(state.copyWith(isSaving: false));

      return result;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return null;
    }
  }

  Future<bool> updateBusinessInfo({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
    required String successMessage,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    try {
      await retailerProfileRepository.updateBusinessInfo(
        fullName: fullName,
        storeName: storeName,
        phoneNumber: phoneNumber,
        storeAddress: storeAddress,
        city: city,
        businessType: businessType,
      );

      final profile = await retailerProfileRepository.getProfile();

      emit(
        state.copyWith(
          isSaving: false,
          profile: profile,
          successMessage: successMessage,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<bool> verifyEmailChange(String code) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await retailerProfileRepository.verifyEmailChange(code: code);

      final profile = await retailerProfileRepository.getProfile();

      emit(state.copyWith(isSaving: false, profile: profile));

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<bool> resendEmailChangeCode() async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await retailerProfileRepository.resendEmailChangeCode();
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<bool> sendPasswordResetCode({required String email}) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await retailerProfileRepository.sendPasswordResetCode(email: email);
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<bool> updatePasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await retailerProfileRepository.updatePasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      emit(state.copyWith(isSaving: false));

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    emit(
      state.copyWith(
        isDeletingAccount: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await retailerProfileRepository.deleteAccount(password: password);

      emit(
        state.copyWith(isDeletingAccount: false, accountDeletedSuccess: true),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isDeletingAccount: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );

      return false;
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoggingOut: true, clearError: true));

    try {
      await retailerProfileRepository.logout();

      emit(state.copyWith(isLoggingOut: false, logoutSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isLoggingOut: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}

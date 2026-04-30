import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
    required String successMessage,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    try {
      final profile = await retailerProfileRepository.updateProfile(
        username: username,
        firstName: firstName,
        lastName: lastName,
        storeName: storeName,
        phoneNumber: phoneNumber,
        storeAddress: storeAddress,
        city: city,
        businessType: businessType,
      );

      emit(
        state.copyWith(
          isSaving: false,
          profile: profile,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
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

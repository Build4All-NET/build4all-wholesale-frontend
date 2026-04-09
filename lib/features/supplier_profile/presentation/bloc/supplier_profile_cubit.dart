import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_supplier_profile_usecase.dart';
import 'supplier_profile_state.dart';

class SupplierProfileCubit extends Cubit<SupplierProfileState> {
  final CreateSupplierProfileUseCase createSupplierProfileUseCase;

  SupplierProfileCubit({
    required this.createSupplierProfileUseCase,
  }) : super(const SupplierProfileState());

  Future<void> createSupplierProfile({
    required int userId,
    required String companyName,
    required String companyAddress,
    required String phoneNumber,
    required String city,
    required String businessType,
    required String description,
    required String logoUrl,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        success: false,
        clearError: true,
      ),
    );

    try {
      final profile = await createSupplierProfileUseCase(
        userId: userId,
        companyName: companyName,
        companyAddress: companyAddress,
        phoneNumber: phoneNumber,
        city: city,
        businessType: businessType,
        description: description,
        logoUrl: logoUrl,
      );

      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          success: true,
          errorMessage: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          success: false,
        ),
      );
    }
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearError: true,
        success: false,
      ),
    );
  }
}

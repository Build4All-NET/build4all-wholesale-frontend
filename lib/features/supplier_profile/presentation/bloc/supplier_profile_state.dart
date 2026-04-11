import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier_profile_entity.dart';

class SupplierProfileState extends Equatable {
  final bool isLoading;
  final SupplierProfileEntity? profile;
  final String? errorMessage;
  final bool success;

  const SupplierProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.success = false,
  });

  SupplierProfileState copyWith({
    bool? isLoading,
    SupplierProfileEntity? profile,
    String? errorMessage,
    bool? success,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return SupplierProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        profile,
        errorMessage,
        success,
      ];
}

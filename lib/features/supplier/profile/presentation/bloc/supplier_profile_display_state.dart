import '../../domain/entities/supplier_profile_display_entity.dart';

class SupplierProfileDisplayState {
  final bool loading;
  final bool refreshing;
  final SupplierProfileDisplayEntity? profile;
  final String? errorMessage;

  SupplierProfileDisplayState({
    this.loading = false,
    this.refreshing = false,
    this.profile,
    this.errorMessage,
  });

  SupplierProfileDisplayState copyWith({
    bool? loading,
    bool? refreshing,
    SupplierProfileDisplayEntity? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierProfileDisplayState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

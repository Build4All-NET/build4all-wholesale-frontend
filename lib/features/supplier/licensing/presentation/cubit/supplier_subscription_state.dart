import '../../domain/entities/owner_app_access.dart';

class SupplierSubscriptionState {
  final bool isLoading;
  final OwnerAppAccess? access;
  final String? errorMessage;

  const SupplierSubscriptionState({
    required this.isLoading,
    required this.access,
    required this.errorMessage,
  });

  factory SupplierSubscriptionState.initial() =>
      const SupplierSubscriptionState(
        isLoading: false,
        access: null,
        errorMessage: null,
      );

  SupplierSubscriptionState copyWith({
    bool? isLoading,
    OwnerAppAccess? access,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierSubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      access: access ?? this.access,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

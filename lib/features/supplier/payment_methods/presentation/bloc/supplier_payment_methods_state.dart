import '../../domain/entities/supplier_payment_method_entity.dart';

class SupplierPaymentMethodsState {
  final bool isLoading;
  final List<SupplierPaymentMethodEntity> methods;
  final String? savingMethodCode;
  final String? errorMessage;
  final String? successMessage;

  const SupplierPaymentMethodsState({
    required this.isLoading,
    required this.methods,
    required this.savingMethodCode,
    required this.errorMessage,
    required this.successMessage,
  });

  factory SupplierPaymentMethodsState.initial() {
    return const SupplierPaymentMethodsState(
      isLoading: false,
      methods: [],
      savingMethodCode: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  SupplierPaymentMethodsState copyWith({
    bool? isLoading,
    List<SupplierPaymentMethodEntity>? methods,
    String? savingMethodCode,
    bool clearSavingMethodCode = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return SupplierPaymentMethodsState(
      isLoading: isLoading ?? this.isLoading,
      methods: methods ?? this.methods,
      savingMethodCode: clearSavingMethodCode
          ? null
          : savingMethodCode ?? this.savingMethodCode,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

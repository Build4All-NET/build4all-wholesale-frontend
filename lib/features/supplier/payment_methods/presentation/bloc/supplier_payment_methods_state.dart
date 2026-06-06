import '../../domain/entities/supplier_payment_method_entity.dart';

class SupplierPaymentMethodsState {
  final bool isLoading;
  final List<SupplierPaymentMethodEntity> methods;

  /// Code of the method currently being saved/toggled.
  final String? savingMethodCode;

  /// Code of the method currently being tested.
  final String? testingMethodCode;

  /// Last test result message (success or failure).
  final String? testResultMessage;

  /// Whether the last test passed.
  final bool? testResultSuccess;

  final String? errorMessage;
  final String? successMessage;

  const SupplierPaymentMethodsState({
    required this.isLoading,
    required this.methods,
    required this.savingMethodCode,
    required this.testingMethodCode,
    required this.testResultMessage,
    required this.testResultSuccess,
    required this.errorMessage,
    required this.successMessage,
  });

  factory SupplierPaymentMethodsState.initial() {
    return const SupplierPaymentMethodsState(
      isLoading: false,
      methods: [],
      savingMethodCode: null,
      testingMethodCode: null,
      testResultMessage: null,
      testResultSuccess: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  SupplierPaymentMethodsState copyWith({
    bool? isLoading,
    List<SupplierPaymentMethodEntity>? methods,
    String? savingMethodCode,
    bool clearSavingMethodCode = false,
    String? testingMethodCode,
    bool clearTestingMethodCode = false,
    String? testResultMessage,
    bool clearTestResult = false,
    bool? testResultSuccess,
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
      testingMethodCode: clearTestingMethodCode
          ? null
          : testingMethodCode ?? this.testingMethodCode,
      testResultMessage: clearTestResult
          ? null
          : testResultMessage ?? this.testResultMessage,
      testResultSuccess: clearTestResult
          ? null
          : testResultSuccess ?? this.testResultSuccess,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}

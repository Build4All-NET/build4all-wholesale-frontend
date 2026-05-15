import '../../domain/entities/supplier_rfq_request_entity.dart';

class SupplierRfqState {
  final bool isLoading;
  final bool isSubmitting;
  final List<SupplierRfqRequestEntity> rfqs;
  final SupplierRfqRequestEntity? selectedRfq;
  final String? errorMessage;
  final String? successMessage;

  const SupplierRfqState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.rfqs = const [],
    this.selectedRfq,
    this.errorMessage,
    this.successMessage,
  });

  SupplierRfqState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<SupplierRfqRequestEntity>? rfqs,
    SupplierRfqRequestEntity? selectedRfq,
    bool clearSelectedRfq = false,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return SupplierRfqState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      rfqs: rfqs ?? this.rfqs,
      selectedRfq: clearSelectedRfq ? null : selectedRfq ?? this.selectedRfq,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}

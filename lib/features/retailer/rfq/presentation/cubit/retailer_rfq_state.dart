import '../../domain/entities/rfq_request_entity.dart';

class RetailerRfqState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isDeleting;
  final List<RfqRequestEntity> rfqs;
  final RfqRequestEntity? selectedRfq;
  final String? errorMessage;
  final String? successMessage;

  const RetailerRfqState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isDeleting = false,
    this.rfqs = const [],
    this.selectedRfq,
    this.errorMessage,
    this.successMessage,
  });

  RetailerRfqState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDeleting,
    List<RfqRequestEntity>? rfqs,
    RfqRequestEntity? selectedRfq,
    bool clearSelectedRfq = false,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return RetailerRfqState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      rfqs: rfqs ?? this.rfqs,
      selectedRfq: clearSelectedRfq ? null : selectedRfq ?? this.selectedRfq,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}

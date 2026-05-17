import '../../domain/entities/rfq_request_entity.dart';

class RetailerRfqState {
  final bool isLoading;
  final bool isSubmitting;
  final bool isDeleting;
  final bool isAiWriting;
  final List<RfqRequestEntity> rfqs;
  final RfqRequestEntity? selectedRfq;
  final String? aiGeneratedRequirements;
  final String? errorMessage;
  final String? successMessage;

  const RetailerRfqState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.isDeleting = false,
    this.isAiWriting = false,
    this.rfqs = const [],
    this.selectedRfq,
    this.aiGeneratedRequirements,
    this.errorMessage,
    this.successMessage,
  });

  RetailerRfqState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isDeleting,
    bool? isAiWriting,
    List<RfqRequestEntity>? rfqs,
    RfqRequestEntity? selectedRfq,
    bool clearSelectedRfq = false,
    String? aiGeneratedRequirements,
    bool clearAiGeneratedRequirements = false,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return RetailerRfqState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleting: isDeleting ?? this.isDeleting,
      isAiWriting: isAiWriting ?? this.isAiWriting,
      rfqs: rfqs ?? this.rfqs,
      selectedRfq: clearSelectedRfq ? null : selectedRfq ?? this.selectedRfq,
      aiGeneratedRequirements: clearAiGeneratedRequirements
          ? null
          : aiGeneratedRequirements ?? this.aiGeneratedRequirements,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}

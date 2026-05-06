import 'package:equatable/equatable.dart';

import '../../domain/entities/promotion_entity.dart';

class PromotionsState extends Equatable {
  final bool loading;
  final bool saving;
  final bool deleting;
  final List<PromotionEntity> promotions;
  final String? errorMessage;
  final String? successMessage;

  const PromotionsState({
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.promotions = const [],
    this.errorMessage,
    this.successMessage,
  });

  PromotionsState copyWith({
    bool? loading,
    bool? saving,
    bool? deleting,
    List<PromotionEntity>? promotions,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PromotionsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
      promotions: promotions ?? this.promotions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        saving,
        deleting,
        promotions,
        errorMessage,
        successMessage,
      ];
}
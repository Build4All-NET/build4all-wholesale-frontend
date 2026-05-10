import 'package:equatable/equatable.dart';

import '../../domain/entities/coupon_entity.dart';

class CouponsState extends Equatable {
  final bool loading;
  final bool saving;
  final bool deleting;
  final List<CouponEntity> coupons;
  final String? errorMessage;
  final String? successMessage;

  const CouponsState({
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.coupons = const [],
    this.errorMessage,
    this.successMessage,
  });

  CouponsState copyWith({
    bool? loading,
    bool? saving,
    bool? deleting,
    List<CouponEntity>? coupons,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CouponsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
      coupons: coupons ?? this.coupons,
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
        coupons,
        errorMessage,
        successMessage,
      ];
}
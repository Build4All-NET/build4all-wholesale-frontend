import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';
import '../../../../payment/domain/entities/order_payment_entity.dart';

class SupplierOrderDetailsState extends Equatable {
  final bool isLoading;
  final bool isUpdating;
  final bool isPaymentLoading;
  final bool isPaymentUpdating;
  final SupplierOrderEntity? order;
  final OrderPaymentEntity? payment;
  final String? errorMessage;
  final String? successMessage;

  SupplierOrderDetailsState({
    required this.isLoading,
    required this.isUpdating,
    required this.isPaymentLoading,
    required this.isPaymentUpdating,
    required this.order,
    required this.payment,
    this.errorMessage,
    this.successMessage,
  });

  factory SupplierOrderDetailsState.initial() {
    return SupplierOrderDetailsState(
      isLoading: false,
      isUpdating: false,
      isPaymentLoading: false,
      isPaymentUpdating: false,
      order: null,
      payment: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  SupplierOrderDetailsState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isPaymentLoading,
    bool? isPaymentUpdating,
    SupplierOrderEntity? order,
    OrderPaymentEntity? payment,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPayment = false,
  }) {
    return SupplierOrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isPaymentLoading: isPaymentLoading ?? this.isPaymentLoading,
      isPaymentUpdating: isPaymentUpdating ?? this.isPaymentUpdating,
      order: order ?? this.order,
      payment: clearPayment ? null : payment ?? this.payment,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isUpdating,
        isPaymentLoading,
        isPaymentUpdating,
        order,
        payment,
        errorMessage,
        successMessage,
      ];
}

import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

class SupplierOrderDetailsState extends Equatable {
  final bool isLoading;
  final bool isUpdating;
  final SupplierOrderEntity? order;
  final String? errorMessage;
  final String? successMessage;

  SupplierOrderDetailsState({
    required this.isLoading,
    required this.isUpdating,
    required this.order,
    this.errorMessage,
    this.successMessage,
  });

  factory SupplierOrderDetailsState.initial() {
    return SupplierOrderDetailsState(
      isLoading: false,
      isUpdating: false,
      order: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  SupplierOrderDetailsState copyWith({
    bool? isLoading,
    bool? isUpdating,
    SupplierOrderEntity? order,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SupplierOrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      order: order ?? this.order,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isUpdating,
        order,
        errorMessage,
        successMessage,
      ];
}
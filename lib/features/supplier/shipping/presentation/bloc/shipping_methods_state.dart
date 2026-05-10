import 'package:equatable/equatable.dart';

import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodsState extends Equatable {
  final bool loading;
  final bool saving;
  final bool deleting;
  final List<ShippingMethodEntity> methods;
  final String? errorMessage;
  final String? successMessage;

  const ShippingMethodsState({
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.methods = const [],
    this.errorMessage,
    this.successMessage,
  });

  ShippingMethodsState copyWith({
    bool? loading,
    bool? saving,
    bool? deleting,
    List<ShippingMethodEntity>? methods,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ShippingMethodsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
      methods: methods ?? this.methods,
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
        methods,
        errorMessage,
        successMessage,
      ];
}

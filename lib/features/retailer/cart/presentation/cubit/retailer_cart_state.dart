import 'package:equatable/equatable.dart';

import '../../data/models/retailer_cart_model.dart';

class RetailerCartState extends Equatable {
  final bool isLoading;
  final int? updatingItemId;
  final RetailerCartModel? cart;
  final String? errorMessage;

  const RetailerCartState({
    this.isLoading = false,
    this.updatingItemId,
    this.cart,
    this.errorMessage,
  });

  RetailerCartState copyWith({
    bool? isLoading,
    int? updatingItemId,
    bool clearUpdatingItemId = false,
    RetailerCartModel? cart,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RetailerCartState(
      isLoading: isLoading ?? this.isLoading,
      updatingItemId: clearUpdatingItemId
          ? null
          : (updatingItemId ?? this.updatingItemId),
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, updatingItemId, cart, errorMessage];
}

import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;

  /// This stores the product id currently being added.
  /// If null, no product is loading.
  final int? addingProductId;

  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.addingProductId,
    this.home,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAddingToCart => addingProductId != null;

  RetailerHomeState copyWith({
    bool? isLoading,
    int? addingProductId,
    bool clearAddingProductId = false,
    RetailerHomeModel? home,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RetailerHomeState(
      isLoading: isLoading ?? this.isLoading,
      addingProductId: clearAddingProductId
          ? null
          : (addingProductId ?? this.addingProductId),
      home: home ?? this.home,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    addingProductId,
    home,
    errorMessage,
    successMessage,
  ];
}

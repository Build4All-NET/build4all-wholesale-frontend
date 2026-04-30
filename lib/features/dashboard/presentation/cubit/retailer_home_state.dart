import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;
  final bool isAddingToCart;
  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.isAddingToCart = false,
    this.home,
    this.errorMessage,
    this.successMessage,
  });

  RetailerHomeState copyWith({
    bool? isLoading,
    bool? isAddingToCart,
    RetailerHomeModel? home,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RetailerHomeState(
      isLoading: isLoading ?? this.isLoading,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
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
    isAddingToCart,
    home,
    errorMessage,
    successMessage,
  ];
}

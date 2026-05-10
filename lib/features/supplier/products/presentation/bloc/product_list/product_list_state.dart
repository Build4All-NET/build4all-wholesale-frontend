import 'package:equatable/equatable.dart';

import '../../../domain/entities/product_entity.dart';

class ProductListState extends Equatable {
  final bool isLoading;
  final bool isDeleting;
  final List<ProductEntity> products;
  final String? error;
  final String? successMessage;

  const ProductListState({
    required this.isLoading,
    required this.isDeleting,
    required this.products,
    this.error,
    this.successMessage,
  });

  factory ProductListState.initial() {
    return const ProductListState(
      isLoading: false,
      isDeleting: false,
      products: [],
    );
  }

  ProductListState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<ProductEntity>? products,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      products: products ?? this.products,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isDeleting,
        products,
        error,
        successMessage,
      ];
}
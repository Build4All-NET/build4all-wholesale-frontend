import 'package:equatable/equatable.dart';

import '../../../../branches/domain/entities/branch_entity.dart';
import '../../../../branches/domain/entities/branch_inventory_item_entity.dart';
import '../../../domain/entities/product_entity.dart';

class ProductBranchInventoryState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;

  final ProductEntity? product;
  final List<BranchEntity> branches;
  final List<BranchInventoryItemEntity> productInventory;

  final String? error;
  final String? successMessage;

  const ProductBranchInventoryState({
    required this.isLoading,
    required this.isSaving,
    required this.isDeleting,
    required this.product,
    required this.branches,
    required this.productInventory,
    this.error,
    this.successMessage,
  });

  factory ProductBranchInventoryState.initial() {
    return const ProductBranchInventoryState(
      isLoading: false,
      isSaving: false,
      isDeleting: false,
      product: null,
      branches: [],
      productInventory: [],
    );
  }

  ProductBranchInventoryState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    ProductEntity? product,
    List<BranchEntity>? branches,
    List<BranchInventoryItemEntity>? productInventory,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProductBranchInventoryState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      product: product ?? this.product,
      branches: branches ?? this.branches,
      productInventory: productInventory ?? this.productInventory,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  int get totalStock {
    return productInventory.fold<int>(
      0,
      (sum, item) => sum + item.stockQuantity,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        isDeleting,
        product,
        branches,
        productInventory,
        error,
        successMessage,
      ];
}
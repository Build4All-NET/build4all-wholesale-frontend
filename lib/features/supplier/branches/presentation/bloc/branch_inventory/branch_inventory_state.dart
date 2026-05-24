import 'package:equatable/equatable.dart';

import '../../../../products/domain/entities/product_entity.dart';
import '../../../domain/entities/branch_inventory_item_entity.dart';

class BranchInventoryState extends Equatable {
  final bool isLoading;
  final bool isAssigning;
  final bool isUpdating;
  final bool isDeleting;

  final List<BranchInventoryItemEntity> inventoryItems;
  final List<ProductEntity> products;

  final String? error;
  final String? successMessage;

  BranchInventoryState({
    required this.isLoading,
    required this.isAssigning,
    required this.isUpdating,
    required this.isDeleting,
    required this.inventoryItems,
    required this.products,
    this.error,
    this.successMessage,
  });

  factory BranchInventoryState.initial() {
    return BranchInventoryState(
      isLoading: false,
      isAssigning: false,
      isUpdating: false,
      isDeleting: false,
      inventoryItems: [],
      products: [],
    );
  }

  BranchInventoryState copyWith({
    bool? isLoading,
    bool? isAssigning,
    bool? isUpdating,
    bool? isDeleting,
    List<BranchInventoryItemEntity>? inventoryItems,
    List<ProductEntity>? products,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return BranchInventoryState(
      isLoading: isLoading ?? this.isLoading,
      isAssigning: isAssigning ?? this.isAssigning,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      products: products ?? this.products,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAssigning,
        isUpdating,
        isDeleting,
        inventoryItems,
        products,
        error,
        successMessage,
      ];
}
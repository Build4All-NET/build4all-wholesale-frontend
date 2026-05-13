import 'package:equatable/equatable.dart';

import '../../../domain/entities/product_entity.dart';

abstract class ProductBranchInventoryEvent extends Equatable {
  ProductBranchInventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductBranchInventory extends ProductBranchInventoryEvent {
  final ProductEntity product;

  LoadProductBranchInventory({
    required this.product,
  });

  @override
  List<Object?> get props => [product];
}

class AssignProductStockToBranchRequested
    extends ProductBranchInventoryEvent {
  final ProductEntity product;
  final String branchId;
  final int stockQuantity;

  AssignProductStockToBranchRequested({
    required this.product,
    required this.branchId,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [product, branchId, stockQuantity];
}

class UpdateProductBranchStockRequested
    extends ProductBranchInventoryEvent {
  final ProductEntity product;
  final String inventoryId;
  final int stockQuantity;

  UpdateProductBranchStockRequested({
    required this.product,
    required this.inventoryId,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [product, inventoryId, stockQuantity];
}

class DeleteProductBranchInventoryItemRequested
    extends ProductBranchInventoryEvent {
  final ProductEntity product;
  final String inventoryId;

  DeleteProductBranchInventoryItemRequested({
    required this.product,
    required this.inventoryId,
  });

  @override
  List<Object?> get props => [product, inventoryId];
}
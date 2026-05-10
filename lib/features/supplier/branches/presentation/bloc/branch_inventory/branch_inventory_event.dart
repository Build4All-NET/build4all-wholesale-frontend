import 'package:equatable/equatable.dart';

abstract class BranchInventoryEvent extends Equatable {
  const BranchInventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadBranchInventory extends BranchInventoryEvent {
  final String branchId;

  const LoadBranchInventory({
    required this.branchId,
  });

  @override
  List<Object?> get props => [branchId];
}

class AssignProductToBranchRequested extends BranchInventoryEvent {
  final String branchId;
  final String productId;
  final int stockQuantity;

  const AssignProductToBranchRequested({
    required this.branchId,
    required this.productId,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [branchId, productId, stockQuantity];
}

class UpdateBranchInventoryStockRequested extends BranchInventoryEvent {
  final String branchId;
  final String inventoryId;
  final int stockQuantity;

  const UpdateBranchInventoryStockRequested({
    required this.branchId,
    required this.inventoryId,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [branchId, inventoryId, stockQuantity];
}

class DeleteBranchInventoryItemRequested extends BranchInventoryEvent {
  final String branchId;
  final String inventoryId;

  const DeleteBranchInventoryItemRequested({
    required this.branchId,
    required this.inventoryId,
  });

  @override
  List<Object?> get props => [branchId, inventoryId];
}
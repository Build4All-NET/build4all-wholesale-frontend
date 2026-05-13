import 'package:equatable/equatable.dart';

abstract class BranchInventoryEvent extends Equatable {
  BranchInventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadBranchInventory extends BranchInventoryEvent {
  final String branchId;

  LoadBranchInventory({
    required this.branchId,
  });

  @override
  List<Object?> get props => [branchId];
}

class AssignProductToBranchRequested extends BranchInventoryEvent {
  final String branchId;
  final String productId;
  final int stockQuantity;

  AssignProductToBranchRequested({
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

  UpdateBranchInventoryStockRequested({
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

  DeleteBranchInventoryItemRequested({
    required this.branchId,
    required this.inventoryId,
  });

  @override
  List<Object?> get props => [branchId, inventoryId];
}
import '../entities/branch_inventory_item_entity.dart';

abstract class BranchInventoryRepository {
  Future<List<BranchInventoryItemEntity>> getInventoryByBranch({
    required String branchId,
  });

  Future<List<BranchInventoryItemEntity>> getInventoryByProduct({
    required String productId,
  });

  Future<BranchInventoryItemEntity> assignProductToBranch({
    required String branchId,
    required String productId,
    required int stockQuantity,
  });

  Future<BranchInventoryItemEntity> updateStock({
    required String inventoryId,
    required int stockQuantity,
  });

  Future<void> deleteInventoryItem({
    required String inventoryId,
  });
}


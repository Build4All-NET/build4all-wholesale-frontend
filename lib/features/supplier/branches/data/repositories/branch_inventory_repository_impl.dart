import '../../domain/entities/branch_inventory_item_entity.dart';
import '../../domain/repositories/branch_inventory_repository.dart';
import '../services/branch_inventory_api_service.dart';

class BranchInventoryRepositoryImpl implements BranchInventoryRepository {
  final BranchInventoryApiService apiService;

  BranchInventoryRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<BranchInventoryItemEntity>> getInventoryByBranch({
    required String branchId,
  }) {
    return apiService.getInventoryByBranch(branchId: branchId);
  }

  @override
  Future<List<BranchInventoryItemEntity>> getInventoryByProduct({
    required String productId,
  }) {
    return apiService.getInventoryByProduct(productId: productId);
  }

  @override
  Future<BranchInventoryItemEntity> assignProductToBranch({
    required String branchId,
    required String productId,
    required int stockQuantity,
  }) {
    return apiService.assignProductToBranch(
      branchId: branchId,
      productId: productId,
      stockQuantity: stockQuantity,
    );
  }

  @override
  Future<BranchInventoryItemEntity> updateStock({
    required String inventoryId,
    required int stockQuantity,
  }) {
    return apiService.updateStock(
      inventoryId: inventoryId,
      stockQuantity: stockQuantity,
    );
  }

  @override
  Future<void> deleteInventoryItem({
    required String inventoryId,
  }) {
    return apiService.deleteInventoryItem(
      inventoryId: inventoryId,
    );
  }
}
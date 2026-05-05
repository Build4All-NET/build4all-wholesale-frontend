import '../entities/branch_inventory_item_entity.dart';
import '../repositories/branch_inventory_repository.dart';

class UpdateBranchStockUseCase {
  final BranchInventoryRepository repository;

  UpdateBranchStockUseCase(this.repository);

  Future<BranchInventoryItemEntity> call({
    required String inventoryId,
    required int stockQuantity,
  }) {
    return repository.updateStock(
      inventoryId: inventoryId,
      stockQuantity: stockQuantity,
    );
  }
}
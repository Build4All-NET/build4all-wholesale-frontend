import '../repositories/branch_inventory_repository.dart';

class DeleteInventoryItemUseCase {
  final BranchInventoryRepository repository;

  DeleteInventoryItemUseCase(this.repository);

  Future<void> call({
    required String inventoryId,
  }) {
    return repository.deleteInventoryItem(inventoryId: inventoryId);
  }
}
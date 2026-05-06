import '../entities/branch_inventory_item_entity.dart';
import '../repositories/branch_inventory_repository.dart';

class GetInventoryByProductUseCase {
  final BranchInventoryRepository repository;

  GetInventoryByProductUseCase(this.repository);

  Future<List<BranchInventoryItemEntity>> call({
    required String productId,
  }) {
    return repository.getInventoryByProduct(productId: productId);
  }
}
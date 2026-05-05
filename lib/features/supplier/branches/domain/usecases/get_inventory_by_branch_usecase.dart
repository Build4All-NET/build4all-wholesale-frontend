import '../entities/branch_inventory_item_entity.dart';
import '../repositories/branch_inventory_repository.dart';

class GetInventoryByBranchUseCase {
  final BranchInventoryRepository repository;

  GetInventoryByBranchUseCase(this.repository);

  Future<List<BranchInventoryItemEntity>> call({
    required String branchId,
  }) {
    return repository.getInventoryByBranch(branchId: branchId);
  }
}
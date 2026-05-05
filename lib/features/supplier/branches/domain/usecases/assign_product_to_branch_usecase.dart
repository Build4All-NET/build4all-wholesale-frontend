import '../entities/branch_inventory_item_entity.dart';
import '../repositories/branch_inventory_repository.dart';

class AssignProductToBranchUseCase {
  final BranchInventoryRepository repository;

  AssignProductToBranchUseCase(this.repository);

  Future<BranchInventoryItemEntity> call({
    required String branchId,
    required String productId,
    required int stockQuantity,
  }) {
    return repository.assignProductToBranch(
      branchId: branchId,
      productId: productId,
      stockQuantity: stockQuantity,
    );
  }
}
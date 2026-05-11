import '../entities/supplier_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class UpdateCategoryStatusUseCase {
  final SupplierCategoryRepository repository;

  UpdateCategoryStatusUseCase(this.repository);

  Future<SupplierCategoryEntity> call({
    required String categoryId,
    required SupplierCatalogStatus status,
  }) {
    return repository.updateCategoryStatus(
      categoryId: categoryId,
      status: status,
    );
  }
}

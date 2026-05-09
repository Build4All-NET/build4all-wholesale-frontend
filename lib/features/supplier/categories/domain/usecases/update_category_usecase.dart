import '../entities/supplier_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class UpdateCategoryUseCase {
  final SupplierCategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<SupplierCategoryEntity> call({
    required String categoryId,
    required String name,
  }) {
    return repository.updateCategory(
      categoryId: categoryId,
      name: name,
    );
  }
}

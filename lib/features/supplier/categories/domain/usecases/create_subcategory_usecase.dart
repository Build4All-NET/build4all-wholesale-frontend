import '../entities/supplier_sub_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class CreateSubCategoryUseCase {
  final SupplierCategoryRepository repository;

  CreateSubCategoryUseCase(this.repository);

  Future<SupplierSubCategoryEntity> call({
    required String categoryId,
    required String name,
  }) {
    return repository.createSubCategory(
      categoryId: categoryId,
      name: name,
    );
  }
}
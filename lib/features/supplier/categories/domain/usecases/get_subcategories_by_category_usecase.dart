import '../entities/supplier_sub_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class GetSubCategoriesByCategoryUseCase {
  final SupplierCategoryRepository repository;

  GetSubCategoriesByCategoryUseCase(this.repository);

  Future<List<SupplierSubCategoryEntity>> call({
    required String categoryId,
  }) {
    return repository.getSubCategoriesByCategory(categoryId: categoryId);
  }
}
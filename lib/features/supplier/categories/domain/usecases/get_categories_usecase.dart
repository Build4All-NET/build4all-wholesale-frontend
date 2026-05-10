import '../entities/supplier_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class GetCategoriesUseCase {
  final SupplierCategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<SupplierCategoryEntity>> call() {
    return repository.getCategories();
  }
}
import '../entities/supplier_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class GetAllCategoriesUseCase {
  final SupplierCategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  Future<List<SupplierCategoryEntity>> call() {
    return repository.getAllCategories();
  }
}


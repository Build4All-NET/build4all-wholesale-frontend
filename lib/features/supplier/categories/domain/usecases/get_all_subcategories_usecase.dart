import '../entities/supplier_sub_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class GetAllSubCategoriesUseCase {
  final SupplierCategoryRepository repository;

  GetAllSubCategoriesUseCase(this.repository);

  Future<List<SupplierSubCategoryEntity>> call() {
    return repository.getAllSubCategories();
  }
}

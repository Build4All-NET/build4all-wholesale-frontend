import '../entities/supplier_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class CreateCategoryUseCase {
  final SupplierCategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<SupplierCategoryEntity> call({
    required String name,
  }) {
    return repository.createCategory(name: name);
  }
}
import '../entities/supplier_sub_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class UpdateSubCategoryUseCase {
  final SupplierCategoryRepository repository;

  UpdateSubCategoryUseCase(this.repository);

  Future<SupplierSubCategoryEntity> call({
    required String subCategoryId,
    required String name,
  }) {
    return repository.updateSubCategory(
      subCategoryId: subCategoryId,
      name: name,
    );
  }
}


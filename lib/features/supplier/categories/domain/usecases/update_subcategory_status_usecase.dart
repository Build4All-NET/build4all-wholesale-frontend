import '../entities/supplier_category_entity.dart';
import '../entities/supplier_sub_category_entity.dart';
import '../repositories/supplier_category_repository.dart';

class UpdateSubCategoryStatusUseCase {
  final SupplierCategoryRepository repository;

  UpdateSubCategoryStatusUseCase(this.repository);

  Future<SupplierSubCategoryEntity> call({
    required String subCategoryId,
    required SupplierCatalogStatus status,
  }) {
    return repository.updateSubCategoryStatus(
      subCategoryId: subCategoryId,
      status: status,
    );
  }
}

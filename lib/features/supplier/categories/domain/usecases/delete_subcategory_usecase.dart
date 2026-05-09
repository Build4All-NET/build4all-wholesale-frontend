import '../repositories/supplier_category_repository.dart';

class DeleteSubCategoryUseCase {
  final SupplierCategoryRepository repository;

  DeleteSubCategoryUseCase(this.repository);

  Future<void> call({
    required String subCategoryId,
  }) {
    return repository.deleteSubCategory(subCategoryId: subCategoryId);
  }
}

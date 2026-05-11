import '../repositories/supplier_category_repository.dart';

class DeleteCategoryUseCase {
  final SupplierCategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call({
    required String categoryId,
  }) {
    return repository.deleteCategory(categoryId: categoryId);
  }
}

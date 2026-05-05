import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<ProductEntity> call({
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  }) {
    return repository.createProduct(
      name: name,
      description: description,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      price: price,
      minimumOrderQuantity: minimumOrderQuantity,
      status: status,
      imagePath: imagePath,
    );
  }
}
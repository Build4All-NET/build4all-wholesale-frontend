import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();

  Future<List<ProductEntity>> searchProducts({
    required String query,
  });

  Future<ProductEntity> createProduct({
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  });

  Future<ProductEntity> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  });

  Future<void> deleteProduct({
    required String productId,
  });
}
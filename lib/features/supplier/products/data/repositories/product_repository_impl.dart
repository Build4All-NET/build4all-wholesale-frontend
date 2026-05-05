import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../services/product_api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService apiService;

  ProductRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<ProductEntity>> getProducts() {
    return apiService.getProducts();
  }

  @override
  Future<List<ProductEntity>> searchProducts({
    required String query,
  }) {
    return apiService.searchProducts(query: query);
  }

  @override
  Future<ProductEntity> createProduct({
    required String name,
    required String description,
    required String categoryId,
    String? subCategoryId,
    required double price,
    required int minimumOrderQuantity,
    required ProductStatus status,
    String? imagePath,
  }) {
    return apiService.createProduct(
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

  @override
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
  }) {
    return apiService.updateProduct(
      productId: productId,
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

  @override
  Future<void> deleteProduct({
    required String productId,
  }) {
    return apiService.deleteProduct(productId: productId);
  }
}
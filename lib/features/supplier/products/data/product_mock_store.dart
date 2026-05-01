import '../domain/entities/product_entity.dart';
import 'product_mock_data.dart';

class ProductMockStore {
  ProductMockStore._();

  static final List<ProductEntity> products = List<ProductEntity>.from(
    supplierMockProducts,
  );

  static void addProduct(ProductEntity product) {
    products.insert(0, product);
  }

  static void updateProduct(ProductEntity product) {
    final index = products.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      products[index] = product;
    }
  }

  static void deleteProduct(String productId) {
    products.removeWhere((item) => item.id == productId);
  }
}
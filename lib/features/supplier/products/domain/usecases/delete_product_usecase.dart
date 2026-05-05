import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call({
    required String productId,
  }) {
    return repository.deleteProduct(productId: productId);
  }
}
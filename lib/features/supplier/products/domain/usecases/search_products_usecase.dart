import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    required String query,
  }) {
    return repository.searchProducts(query: query);
  }
}
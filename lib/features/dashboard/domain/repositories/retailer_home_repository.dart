import '../../../../core/network/paged_result.dart';
import '../../data/models/retailer_home_model.dart';

abstract class RetailerHomeRepository {
  Future<RetailerHomeModel> getHome();

  Future<PagedResult<HomeProductModel>> getFeaturedProducts({
    required int page,
    required int size,
    String? search,
    int? categoryId,
    int? subCategoryId,
  });

  Future<PagedResult<HomeProductModel>> getProductsByCategory({
    required int categoryId,
    int? subCategoryId,
    String? search,
    required int page,
    required int size,
  });

  Future<HomeProductModel> getProductById(int productId);

  Future<PagedResult<HomeProductModel>> getPromotedProducts({
    required int page,
    required int size,
  });

  Future<PagedResult<HomeProductModel>> searchProducts(
    String query, {
    required int page,
    required int size,
  });

  Future<void> addToCart({required HomeProductModel product, int? quantity});
}

import '../../../../core/network/paged_result.dart';
import '../../domain/repositories/retailer_home_repository.dart';
import '../models/retailer_home_model.dart';
import '../services/retailer_home_service.dart';

class RetailerHomeRepositoryImpl implements RetailerHomeRepository {
  final RetailerHomeService retailerHomeService;

  RetailerHomeRepositoryImpl({required this.retailerHomeService});

  @override
  Future<RetailerHomeModel> getHome() {
    return retailerHomeService.getHome();
  }

  @override
  Future<PagedResult<HomeProductModel>> getFeaturedProducts({
    required int page,
    required int size,
    String? search,
    int? categoryId,
    int? subCategoryId,
  }) {
    return retailerHomeService.getFeaturedProducts(
      page: page,
      size: size,
      search: search,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
    );
  }

  @override
  Future<PagedResult<HomeProductModel>> getProductsByCategory({
    required int categoryId,
    int? subCategoryId,
    String? search,
    required int page,
    required int size,
  }) {
    return retailerHomeService.getProductsByCategory(
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      search: search,
      page: page,
      size: size,
    );
  }

  @override
  Future<HomeProductModel> getProductById(int productId) {
    return retailerHomeService.getProductById(productId);
  }

  @override
  Future<PagedResult<HomeProductModel>> getPromotedProducts({
    required int page,
    required int size,
  }) {
    return retailerHomeService.getPromotedProducts(page: page, size: size);
  }

  @override
  Future<PagedResult<HomeProductModel>> searchProducts(
    String query, {
    required int page,
    required int size,
  }) {
    return retailerHomeService.searchProducts(query, page: page, size: size);
  }

  @override
  Future<void> addToCart({required HomeProductModel product, int? quantity}) {
    return retailerHomeService.addToCart(product: product, quantity: quantity);
  }
}

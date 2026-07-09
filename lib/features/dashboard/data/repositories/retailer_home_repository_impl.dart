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
  Future<HomeProductPageModel> getProducts({
    required int page,
    int size = 20,
    String? search,
    int? categoryId,
    int? subCategoryId,
  }) {
    return retailerHomeService.getProducts(
      page: page,
      size: size,
      search: search,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
    );
  }

  @override
  Future<HomeProductPageModel> getProductsByCategory({
    required int categoryId,
    required int page,
    int size = 20,
    String? search,
    int? subCategoryId,
  }) {
    return retailerHomeService.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      size: size,
      search: search,
      subCategoryId: subCategoryId,
    );
  }

  @override
  Future<HomeProductPageModel> getPromotedProducts({
    required int page,
    int size = 20,
    String? search,
  }) {
    return retailerHomeService.getPromotedProducts(
      page: page,
      size: size,
      search: search,
    );
  }

  @override
  Future<HomeProductPageModel> searchProducts({
    required String query,
    required int page,
    int size = 20,
  }) {
    return retailerHomeService.searchProducts(
      query: query,
      page: page,
      size: size,
    );
  }

  @override
  Future<HomeProductPageModel> getBannerTargetProducts({
    required HomeBannerModel banner,
    required int page,
    int size = 20,
    String? search,
  }) {
    return retailerHomeService.getBannerTargetProducts(
      banner: banner,
      page: page,
      size: size,
      search: search,
    );
  }

  @override
  Future<void> addToCart({required HomeProductModel product, int? quantity}) {
    return retailerHomeService.addToCart(product: product, quantity: quantity);
  }
}

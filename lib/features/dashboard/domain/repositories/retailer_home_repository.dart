import '../../data/models/retailer_home_model.dart';

abstract class RetailerHomeRepository {
  Future<RetailerHomeModel> getHome();

  Future<HomeProductPageModel> getProducts({
    required int page,
    int size,
    String? search,
    int? categoryId,
    int? subCategoryId,
  });

  Future<HomeProductPageModel> getProductsByCategory({
    required int categoryId,
    required int page,
    int size,
    String? search,
    int? subCategoryId,
  });

  Future<HomeProductPageModel> getPromotedProducts({
    required int page,
    int size,
    String? search,
  });

  Future<HomeProductPageModel> searchProducts({
    required String query,
    required int page,
    int size,
  });

  Future<HomeProductPageModel> getBannerTargetProducts({
    required HomeBannerModel banner,
    required int page,
    int size,
    String? search,
  });

  Future<void> addToCart({required HomeProductModel product, int? quantity});
}

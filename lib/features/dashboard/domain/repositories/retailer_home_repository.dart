import '../../data/models/retailer_home_model.dart';

abstract class RetailerHomeRepository {
  Future<RetailerHomeModel> getHome();

  Future<List<HomeProductModel>> getProductsByCategory({
    required int categoryId,
  });

  Future<List<HomeProductModel>> getPromotedProducts();

  Future<void> addToCart({required HomeProductModel product});
}

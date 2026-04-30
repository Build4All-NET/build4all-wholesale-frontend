import '../../../auth/data/models/api_response_model.dart';
import '../../data/models/retailer_home_model.dart';

abstract class RetailerHomeRepository {
  Future<RetailerHomeModel> getHome();

  Future<ApiResponseModel> addToCart({
    required int productId,
    required int quantity,
  });
}

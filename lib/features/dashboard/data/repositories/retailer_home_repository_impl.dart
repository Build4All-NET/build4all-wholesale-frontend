import '../../../auth/data/models/api_response_model.dart';
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
  Future<ApiResponseModel> addToCart({
    required int productId,
    required int quantity,
  }) {
    return retailerHomeService.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }
}

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
  Future<void> addToCart({required HomeProductModel product}) {
    return retailerHomeService.addToCart(product: product);
  }
}

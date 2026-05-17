import '../../domain/repositories/retailer_product_ai_repository.dart';
import '../services/retailer_product_ai_service.dart';

class RetailerProductAiRepositoryImpl implements RetailerProductAiRepository {
  final RetailerProductAiService retailerProductAiService;

  RetailerProductAiRepositoryImpl({required this.retailerProductAiService});

  @override
  Future<String> chatAboutProduct({
    required int productId,
    required String message,
  }) async {
    final response = await retailerProductAiService.chatAboutProduct(
      productId: productId,
      message: message,
    );

    return response.answer;
  }
}

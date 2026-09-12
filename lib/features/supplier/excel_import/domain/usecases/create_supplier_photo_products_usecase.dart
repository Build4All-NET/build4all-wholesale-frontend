import '../../data/services/supplier_product_ai_api_service.dart';

/// Creates the products a supplier assembled from photographs, with no
/// spreadsheet behind them.
class CreateSupplierPhotoProductsUseCase {
  final SupplierProductAiApiService apiService;

  CreateSupplierPhotoProductsUseCase({required this.apiService});

  Future<void> call(List<Map<String, Object?>> products) {
    return apiService.createProducts(products);
  }
}

import '../../data/services/supplier_product_ai_api_service.dart';

/// Asks the assistant to describe photographed products that are not
/// products yet.
class DraftSupplierProductDescriptionsUseCase {
  final SupplierProductAiApiService apiService;

  DraftSupplierProductDescriptionsUseCase({required this.apiService});

  Future<Map<int, String>> call(List<Map<String, Object?>> rows) {
    return apiService.draftDescriptions(rows);
  }
}

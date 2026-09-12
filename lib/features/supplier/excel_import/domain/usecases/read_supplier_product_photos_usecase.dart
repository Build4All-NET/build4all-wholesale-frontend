import '../../data/services/supplier_product_ai_api_service.dart';
import '../entities/photographed_supplier_product_entity.dart';

/// Stores a batch of photographs and asks what each one is.
class ReadSupplierProductPhotosUseCase {
  final SupplierProductAiApiService apiService;

  ReadSupplierProductPhotosUseCase({required this.apiService});

  Future<List<PhotographedSupplierProductEntity>> call(List<String> paths) {
    return apiService.readPhotos(paths);
  }
}

import '../../data/services/supplier_product_ai_api_service.dart';

/// Whether the server's AI features are reachable right now.
///
/// Asked once when the import screen opens, before any AI option is offered,
/// so a supplier on a server with no Gemini key configured never sees a button
/// that quietly does nothing.
class CheckSupplierAiAvailabilityUseCase {
  final SupplierProductAiApiService apiService;

  CheckSupplierAiAvailabilityUseCase({required this.apiService});

  Future<({bool photosAvailable, bool descriptionsAvailable})> call() async {
    final photos = await apiService.photosAvailable();
    final descriptions = await apiService.descriptionsAvailable();
    return (photosAvailable: photos, descriptionsAvailable: descriptions);
  }
}

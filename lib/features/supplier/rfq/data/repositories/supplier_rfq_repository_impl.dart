import '../../domain/entities/supplier_rfq_request_entity.dart';
import '../../domain/repositories/supplier_rfq_repository.dart';
import '../services/supplier_rfq_api_service.dart';

class SupplierRfqRepositoryImpl implements SupplierRfqRepository {
  final SupplierRfqApiService apiService;

  SupplierRfqRepositoryImpl({required this.apiService});

  @override
  Future<List<SupplierRfqRequestEntity>> getOpenRfqs() {
    return apiService.getOpenRfqs();
  }

  @override
  Future<SupplierRfqRequestEntity> getRfqDetails(int rfqId) {
    return apiService.getRfqDetails(rfqId);
  }

  @override
  Future<void> submitQuotation({
    required int rfqId,
    required SupplierQuotationParams params,
  }) {
    return apiService.submitQuotation(rfqId: rfqId, params: params);
  }

  @override
  Future<void> updateQuotation({
    required int quotationId,
    required SupplierQuotationParams params,
  }) {
    return apiService.updateQuotation(quotationId: quotationId, params: params);
  }

  @override
  Future<void> withdrawQuotation(int quotationId) {
    return apiService.withdrawQuotation(quotationId);
  }
}

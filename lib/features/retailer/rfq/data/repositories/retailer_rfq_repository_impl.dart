import '../../domain/entities/rfq_quotation_entity.dart';
import '../../domain/entities/rfq_request_entity.dart';
import '../../domain/repositories/retailer_rfq_repository.dart';
import '../services/retailer_rfq_api_service.dart';

class RetailerRfqRepositoryImpl implements RetailerRfqRepository {
  final RetailerRfqApiService apiService;

  RetailerRfqRepositoryImpl({required this.apiService});

  @override
  Future<List<RfqRequestEntity>> getMyRfqs() {
    return apiService.getMyRfqs();
  }

  @override
  Future<RfqRequestEntity> getRfqDetails(int rfqId) {
    return apiService.getRfqDetails(rfqId);
  }

  @override
  Future<RfqRequestEntity> createRfq(CreateRfqParams params) {
    return apiService.createRfq(params);
  }

  @override
  Future<RfqRequestEntity> updateRfq({
    required int rfqId,
    required UpdateRfqParams params,
  }) {
    return apiService.updateRfq(rfqId: rfqId, params: params);
  }

  @override
  Future<RfqRequestEntity> cancelRfq(int rfqId) {
    return apiService.cancelRfq(rfqId);
  }

  @override
  Future<void> deleteRfq(int rfqId) {
    return apiService.deleteRfq(rfqId);
  }

  @override
  Future<List<RfqQuotationEntity>> getRfqQuotations(int rfqId) {
    return apiService.getRfqQuotations(rfqId);
  }

  @override
  Future<RfqRequestEntity> acceptQuotation({
    required int rfqId,
    required int quotationId,
  }) {
    return apiService.acceptQuotation(rfqId: rfqId, quotationId: quotationId);
  }

  @override
  Future<String> generateRequirementsWithAi(
    GenerateRfqRequirementsParams params,
  ) {
    return apiService.generateRequirementsWithAi(params);
  }
}

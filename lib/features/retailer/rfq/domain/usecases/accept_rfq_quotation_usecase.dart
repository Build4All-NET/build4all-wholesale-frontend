import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class AcceptRfqQuotationUseCase {
  final RetailerRfqRepository repository;

  AcceptRfqQuotationUseCase(this.repository);

  Future<RfqRequestEntity> call({
    required int rfqId,
    required int quotationId,
  }) {
    return repository.acceptQuotation(rfqId: rfqId, quotationId: quotationId);
  }
}

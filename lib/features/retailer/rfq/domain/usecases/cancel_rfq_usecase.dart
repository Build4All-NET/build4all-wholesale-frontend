import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class CancelRfqUseCase {
  final RetailerRfqRepository repository;

  CancelRfqUseCase(this.repository);

  Future<RfqRequestEntity> call(int rfqId) {
    return repository.cancelRfq(rfqId);
  }
}

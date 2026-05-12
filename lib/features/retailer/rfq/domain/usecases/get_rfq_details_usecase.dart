import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class GetRfqDetailsUseCase {
  final RetailerRfqRepository repository;

  GetRfqDetailsUseCase(this.repository);

  Future<RfqRequestEntity> call(int rfqId) {
    return repository.getRfqDetails(rfqId);
  }
}

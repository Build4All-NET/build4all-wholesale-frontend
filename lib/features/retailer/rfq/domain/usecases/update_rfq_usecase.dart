import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class UpdateRfqUseCase {
  final RetailerRfqRepository repository;

  UpdateRfqUseCase(this.repository);

  Future<RfqRequestEntity> call({
    required int rfqId,
    required UpdateRfqParams params,
  }) {
    return repository.updateRfq(rfqId: rfqId, params: params);
  }
}

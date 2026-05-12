import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class CreateRfqUseCase {
  final RetailerRfqRepository repository;

  CreateRfqUseCase(this.repository);

  Future<RfqRequestEntity> call(CreateRfqParams params) {
    return repository.createRfq(params);
  }
}
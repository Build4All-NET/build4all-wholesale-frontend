import '../entities/rfq_request_entity.dart';
import '../repositories/retailer_rfq_repository.dart';

class GetMyRfqsUseCase {
  final RetailerRfqRepository repository;

  GetMyRfqsUseCase(this.repository);

  Future<List<RfqRequestEntity>> call() {
    return repository.getMyRfqs();
  }
}

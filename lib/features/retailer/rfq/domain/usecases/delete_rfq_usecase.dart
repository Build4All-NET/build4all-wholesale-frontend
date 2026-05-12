import '../repositories/retailer_rfq_repository.dart';

class DeleteRfqUseCase {
  final RetailerRfqRepository repository;

  DeleteRfqUseCase(this.repository);

  Future<void> call(int rfqId) {
    return repository.deleteRfq(rfqId);
  }
}

import '../repositories/retailer_rfq_repository.dart';

class GenerateRfqRequirementsUseCase {
  final RetailerRfqRepository repository;

  GenerateRfqRequirementsUseCase(this.repository);

  Future<String> call(GenerateRfqRequirementsParams params) {
    return repository.generateRequirementsWithAi(params);
  }
}

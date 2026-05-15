import '../entities/supplier_rfq_request_entity.dart';
import '../repositories/supplier_rfq_repository.dart';

class GetOpenSupplierRfqsUseCase {
  final SupplierRfqRepository repository;
  GetOpenSupplierRfqsUseCase(this.repository);
  Future<List<SupplierRfqRequestEntity>> call() => repository.getOpenRfqs();
}

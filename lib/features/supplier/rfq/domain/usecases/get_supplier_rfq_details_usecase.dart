import '../entities/supplier_rfq_request_entity.dart';
import '../repositories/supplier_rfq_repository.dart';

class GetSupplierRfqDetailsUseCase {
  final SupplierRfqRepository repository;
  GetSupplierRfqDetailsUseCase(this.repository);
  Future<SupplierRfqRequestEntity> call(int rfqId) => repository.getRfqDetails(rfqId);
}

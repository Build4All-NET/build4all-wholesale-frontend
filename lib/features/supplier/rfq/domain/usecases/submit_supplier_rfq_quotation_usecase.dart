import '../repositories/supplier_rfq_repository.dart';

class SubmitSupplierRfqQuotationUseCase {
  final SupplierRfqRepository repository;
  SubmitSupplierRfqQuotationUseCase(this.repository);
  Future<void> call({required int rfqId, required SupplierQuotationParams params}) {
    return repository.submitQuotation(rfqId: rfqId, params: params);
  }
}

import '../repositories/supplier_rfq_repository.dart';

class UpdateSupplierRfqQuotationUseCase {
  final SupplierRfqRepository repository;
  UpdateSupplierRfqQuotationUseCase(this.repository);
  Future<void> call({required int quotationId, required SupplierQuotationParams params}) {
    return repository.updateQuotation(quotationId: quotationId, params: params);
  }
}

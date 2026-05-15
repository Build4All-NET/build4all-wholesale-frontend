import '../repositories/supplier_rfq_repository.dart';

class WithdrawSupplierRfqQuotationUseCase {
  final SupplierRfqRepository repository;
  WithdrawSupplierRfqQuotationUseCase(this.repository);
  Future<void> call(int quotationId) => repository.withdrawQuotation(quotationId);
}

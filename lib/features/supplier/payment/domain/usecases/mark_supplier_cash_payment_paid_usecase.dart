import '../entities/order_payment_entity.dart';
import '../repositories/supplier_payment_repository.dart';

class MarkSupplierCashPaymentPaidUseCase {
  final SupplierPaymentRepository repository;

  MarkSupplierCashPaymentPaidUseCase(this.repository);

  Future<OrderPaymentEntity> call({
    required int orderId,
  }) {
    return repository.markCashAsPaid(orderId: orderId);
  }
}

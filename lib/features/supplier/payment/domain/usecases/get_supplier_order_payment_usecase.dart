import '../entities/order_payment_entity.dart';
import '../repositories/supplier_payment_repository.dart';

class GetSupplierOrderPaymentUseCase {
  final SupplierPaymentRepository repository;

  GetSupplierOrderPaymentUseCase(this.repository);

  Future<OrderPaymentEntity> call({
    required int orderId,
  }) {
    return repository.getOrderPayment(orderId: orderId);
  }
}

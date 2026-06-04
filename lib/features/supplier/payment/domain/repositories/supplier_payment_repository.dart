import '../entities/order_payment_entity.dart';

abstract class SupplierPaymentRepository {
  Future<OrderPaymentEntity> getOrderPayment({
    required int orderId,
  });

  Future<OrderPaymentEntity> markCashAsPaid({
    required int orderId,
  });
}

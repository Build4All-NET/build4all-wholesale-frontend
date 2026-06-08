import '../../domain/entities/order_payment_entity.dart';
import '../../domain/repositories/supplier_payment_repository.dart';
import '../services/supplier_payment_api_service.dart';

class SupplierPaymentRepositoryImpl implements SupplierPaymentRepository {
  final SupplierPaymentApiService apiService;

  SupplierPaymentRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<OrderPaymentEntity> getOrderPayment({
    required int orderId,
  }) {
    return apiService.getOrderPayment(orderId: orderId);
  }

  @override
  Future<OrderPaymentEntity> markCashAsPaid({
    required int orderId,
  }) {
    return apiService.markCashAsPaid(orderId: orderId);
  }
}
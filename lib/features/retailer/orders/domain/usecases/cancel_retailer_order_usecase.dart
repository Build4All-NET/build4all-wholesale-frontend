import '../entities/retailer_order_entity.dart';
import '../repositories/retailer_order_repository.dart';

class CancelRetailerOrderUseCase {
  final RetailerOrderRepository repository;

  CancelRetailerOrderUseCase(this.repository);

  Future<RetailerOrderEntity> call({required int orderId}) {
    return repository.cancelOrder(orderId: orderId);
  }
}

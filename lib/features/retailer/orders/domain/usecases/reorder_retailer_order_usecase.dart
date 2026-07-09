import '../entities/reorder_cart_result_entity.dart';
import '../repositories/retailer_order_repository.dart';

class ReorderRetailerOrderUseCase {
  final RetailerOrderRepository repository;

  ReorderRetailerOrderUseCase(this.repository);

  Future<ReorderCartResultEntity> call({
    required int orderId,
    String mode = 'REPLACE',
  }) {
    return repository.reorder(orderId: orderId, mode: mode);
  }
}

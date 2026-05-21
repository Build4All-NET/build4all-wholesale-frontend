import '../repositories/retailer_order_repository.dart';

class ReorderRetailerOrderUseCase {
  final RetailerOrderRepository repository;

  ReorderRetailerOrderUseCase(this.repository);

  Future<void> call({required int orderId}) {
    return repository.reorder(orderId: orderId);
  }
}

import '../entities/retailer_order_entity.dart';
import '../repositories/retailer_order_repository.dart';

class GetRetailerOrdersUseCase {
  final RetailerOrderRepository repository;

  GetRetailerOrdersUseCase(this.repository);

  Future<List<RetailerOrderEntity>> call() {
    return repository.getOrders();
  }
}

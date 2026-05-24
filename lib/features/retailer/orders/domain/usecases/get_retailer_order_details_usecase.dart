import '../entities/retailer_order_entity.dart';
import '../repositories/retailer_order_repository.dart';

class GetRetailerOrderDetailsUseCase {
  final RetailerOrderRepository repository;

  GetRetailerOrderDetailsUseCase(this.repository);

  Future<RetailerOrderEntity> call({required int orderId}) {
    return repository.getOrderDetails(orderId: orderId);
  }
}

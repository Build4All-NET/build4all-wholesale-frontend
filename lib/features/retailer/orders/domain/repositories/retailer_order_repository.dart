import '../entities/retailer_order_entity.dart';

abstract class RetailerOrderRepository {
  Future<List<RetailerOrderEntity>> getOrders();

  Future<RetailerOrderEntity> getOrderDetails({required int orderId});

  Future<RetailerOrderEntity> cancelOrder({required int orderId});

  Future<void> reorder({required int orderId});
}

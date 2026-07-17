import '../entities/retailer_order_entity.dart';
import '../entities/skipped_reorder_item_entity.dart';

abstract class RetailerOrderRepository {
  Future<List<RetailerOrderEntity>> getOrders();

  Future<RetailerOrderEntity> getOrderDetails({required int orderId});

  Future<RetailerOrderEntity> cancelOrder({required int orderId});

  Future<List<SkippedReorderItemEntity>> reorder({
    required int orderId,
    required String mode,
  });
}

import '../entities/supplier_order_entity.dart';

abstract class SupplierOrderRepository {
  Future<List<SupplierOrderEntity>> getOrders();

  Future<List<SupplierOrderEntity>> searchOrders({
    required String query,
    SupplierOrderStatus? status,
  });

  Future<SupplierOrderEntity> getOrderDetails({
    required int orderId,
  });

  Future<SupplierOrderEntity> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  });

  // Temporary compatibility for dashboard until we move dashboard to Bloc/API later.
  List<SupplierOrderEntity> getCurrentOrders();

  int countByStatus(SupplierOrderStatus status);
}
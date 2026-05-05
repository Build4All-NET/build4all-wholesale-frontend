import '../entities/supplier_order_entity.dart';

abstract class SupplierOrderRepository {
  Future<List<SupplierOrderEntity>> getOrders();

  List<SupplierOrderEntity> getCurrentOrders();

  Future<List<SupplierOrderEntity>> searchOrders({
    required String query,
    SupplierOrderStatus? status,
  });

  Future<SupplierOrderEntity> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  });

  int countByStatus(SupplierOrderStatus status);
}
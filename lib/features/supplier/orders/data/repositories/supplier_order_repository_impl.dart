import '../../domain/entities/supplier_order_entity.dart';
import '../../domain/repositories/supplier_order_repository.dart';
import '../services/supplier_order_api_service.dart';

class SupplierOrderRepositoryImpl implements SupplierOrderRepository {
  final SupplierOrderApiService apiService;

  List<SupplierOrderEntity> _cachedOrders = [];

  SupplierOrderRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<SupplierOrderEntity>> getOrders() async {
    final orders = await apiService.getOrders();
    _cachedOrders = orders;
    return orders;
  }

  @override
  Future<List<SupplierOrderEntity>> searchOrders({
    required String query,
    SupplierOrderStatus? status,
  }) async {
    final orders = status == null
        ? await apiService.getOrders()
        : await apiService.getOrdersByStatus(status: status);

    final normalizedQuery = query.trim().toLowerCase();

    final filteredOrders = normalizedQuery.isEmpty
        ? orders
        : orders.where((order) {
            return order.orderNumber.toLowerCase().contains(normalizedQuery) ||
                order.retailerName.toLowerCase().contains(normalizedQuery) ||
                order.deliveryAddress.toLowerCase().contains(normalizedQuery) ||
                order.paymentMethod.toLowerCase().contains(normalizedQuery);
          }).toList();

    _cachedOrders = orders;
    return filteredOrders;
  }

  @override
  Future<SupplierOrderEntity> getOrderDetails({
    required int orderId,
  }) {
    return apiService.getOrderDetails(orderId: orderId);
  }

  @override
  Future<SupplierOrderEntity> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  }) async {
    final updatedOrder = await apiService.updateOrderStatus(
      orderId: orderId,
      status: status,
    );

    _cachedOrders = _cachedOrders.map((order) {
      return order.id == updatedOrder.id ? updatedOrder : order;
    }).toList();

    return updatedOrder;
  }

  @override
  List<SupplierOrderEntity> getCurrentOrders() {
    return List<SupplierOrderEntity>.from(_cachedOrders);
  }

  @override
  int countByStatus(SupplierOrderStatus status) {
    return _cachedOrders.where((order) => order.status == status).length;
  }
}
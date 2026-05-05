import '../../domain/entities/supplier_order_entity.dart';
import '../../domain/repositories/supplier_order_repository.dart';
import '../mock_store/supplier_order_mock_store.dart';

class SupplierOrderRepositoryImpl implements SupplierOrderRepository {
  final SupplierOrderMockStore mockStore;

  SupplierOrderRepositoryImpl({
    SupplierOrderMockStore? mockStore,
  }) : mockStore = mockStore ?? SupplierOrderMockStore();

  @override
  Future<List<SupplierOrderEntity>> getOrders() {
    return mockStore.getOrders();
  }

  @override
  List<SupplierOrderEntity> getCurrentOrders() {
    return mockStore.getCurrentOrders();
  }

  @override
  Future<List<SupplierOrderEntity>> searchOrders({
    required String query,
    SupplierOrderStatus? status,
  }) {
    return mockStore.searchOrders(
      query: query,
      status: status,
    );
  }

  @override
  Future<SupplierOrderEntity> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  }) {
    return mockStore.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }

  @override
  int countByStatus(SupplierOrderStatus status) {
    return mockStore.countByStatus(status);
  }
}
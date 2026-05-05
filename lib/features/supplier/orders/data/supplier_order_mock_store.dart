import '../domain/entities/supplier_order_entity.dart';
import '../domain/entities/supplier_order_item_entity.dart';

class SupplierOrderMockStore {
  static final List<SupplierOrderEntity> _orders = [
    SupplierOrderEntity(
      id: 1,
      orderNumber: 'ORD-001',
      retailerName: 'ABC Store',
      retailerPhone: '+961 70 111 222',
      deliveryAddress: '123 Main Street, Beirut',
      branchName: 'Beirut Branch',
      orderDate: DateTime(2026, 3, 12, 10, 30),
      paymentMethod: 'Wallet',
      status: SupplierOrderStatus.pending,
      notes: 'Please deliver before afternoon.',
      items: const [
        SupplierOrderItemEntity(
          productId: 1,
          productName: 'Coca-Cola 24-Pack',
          quantity: 10,
          unitPrice: 18.99,
        ),
        SupplierOrderItemEntity(
          productId: 2,
          productName: 'Potato Chips 50-Pack',
          quantity: 5,
          unitPrice: 45.00,
        ),
      ],
    ),
    SupplierOrderEntity(
      id: 2,
      orderNumber: 'ORD-002',
      retailerName: 'XYZ Market',
      retailerPhone: '+961 71 333 444',
      deliveryAddress: 'Hamra Street, Beirut',
      branchName: 'Main Warehouse',
      orderDate: DateTime(2026, 3, 12, 11, 0),
      paymentMethod: 'Card',
      status: SupplierOrderStatus.pending,
      items: const [
        SupplierOrderItemEntity(
          productId: 3,
          productName: 'Mineral Water 12-Pack',
          quantity: 20,
          unitPrice: 6.75,
        ),
        SupplierOrderItemEntity(
          productId: 4,
          productName: 'Chocolate Box',
          quantity: 10,
          unitPrice: 19.00,
        ),
      ],
    ),
    SupplierOrderEntity(
      id: 3,
      orderNumber: 'ORD-003',
      retailerName: 'Fresh Corner',
      retailerPhone: '+961 76 555 888',
      deliveryAddress: 'Tripoli, Mina Road',
      branchName: 'Tripoli Branch',
      orderDate: DateTime(2026, 3, 13, 9, 15),
      paymentMethod: 'Cash',
      status: SupplierOrderStatus.preparing,
      items: const [
        SupplierOrderItemEntity(
          productId: 5,
          productName: 'Rice Bag 25kg',
          quantity: 8,
          unitPrice: 32.50,
        ),
      ],
    ),
    SupplierOrderEntity(
      id: 4,
      orderNumber: 'ORD-004',
      retailerName: 'Daily Needs',
      retailerPhone: '+961 81 222 999',
      deliveryAddress: 'Saida Old Road',
      branchName: 'Saida Branch',
      orderDate: DateTime(2026, 3, 13, 13, 45),
      paymentMethod: 'Wallet',
      status: SupplierOrderStatus.shipped,
      items: const [
        SupplierOrderItemEntity(
          productId: 6,
          productName: 'Cleaning Detergent Carton',
          quantity: 6,
          unitPrice: 27.25,
        ),
        SupplierOrderItemEntity(
          productId: 7,
          productName: 'Tissue Pack Bundle',
          quantity: 12,
          unitPrice: 8.50,
        ),
      ],
    ),
    SupplierOrderEntity(
      id: 5,
      orderNumber: 'ORD-005',
      retailerName: 'City Supermarket',
      retailerPhone: '+961 03 444 777',
      deliveryAddress: 'Zahle Main Road',
      branchName: 'Bekaa Branch',
      orderDate: DateTime(2026, 3, 14, 16, 20),
      paymentMethod: 'Card',
      status: SupplierOrderStatus.delivered,
      items: const [
        SupplierOrderItemEntity(
          productId: 8,
          productName: 'Milk Carton Box',
          quantity: 15,
          unitPrice: 11.25,
        ),
      ],
    ),
  ];

 Future<List<SupplierOrderEntity>> getOrders() async {
  await Future.delayed(const Duration(milliseconds: 250));
  return List<SupplierOrderEntity>.from(_orders);
}

List<SupplierOrderEntity> getCurrentOrders() {
  return List<SupplierOrderEntity>.from(_orders);
}

  Future<List<SupplierOrderEntity>> searchOrders({
    required String query,
    SupplierOrderStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final normalizedQuery = query.trim().toLowerCase();

    return _orders.where((order) {
      final matchesQuery = normalizedQuery.isEmpty ||
          order.orderNumber.toLowerCase().contains(normalizedQuery) ||
          order.retailerName.toLowerCase().contains(normalizedQuery) ||
          order.deliveryAddress.toLowerCase().contains(normalizedQuery) ||
          order.paymentMethod.toLowerCase().contains(normalizedQuery);

      final matchesStatus = status == null || order.status == status;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<SupplierOrderEntity> updateOrderStatus({
    required int orderId,
    required SupplierOrderStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final index = _orders.indexWhere((order) => order.id == orderId);

    if (index == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _orders[index].copyWith(status: status);
    _orders[index] = updatedOrder;

    return updatedOrder;
  }

  int countByStatus(SupplierOrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }
}
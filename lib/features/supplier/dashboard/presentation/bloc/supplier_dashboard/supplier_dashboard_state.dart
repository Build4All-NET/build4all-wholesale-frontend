import 'package:equatable/equatable.dart';

import '../../../../orders/domain/entities/supplier_order_entity.dart';

class SupplierDashboardState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<SupplierOrderEntity> orders;
  final String? errorMessage;

  const SupplierDashboardState({
    required this.isLoading,
    required this.isRefreshing,
    required this.orders,
    this.errorMessage,
  });

  factory SupplierDashboardState.initial() {
    return const SupplierDashboardState(
      isLoading: false,
      isRefreshing: false,
      orders: [],
      errorMessage: null,
    );
  }

  int get pendingOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.pending)
        .length;
  }

  int get acceptedOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.accepted)
        .length;
  }

  int get preparingOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.preparing)
        .length;
  }

  int get activeOrders {
    return acceptedOrders + preparingOrders;
  }

  int get shippedOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.shipped)
        .length;
  }

  int get completedOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.delivered)
        .length;
  }

  int get cancelledOrders {
    return orders
        .where((order) => order.status == SupplierOrderStatus.cancelled)
        .length;
  }

  int get totalOrdersToday {
    final now = DateTime.now();

    return orders.where((order) {
      return order.orderDate.year == now.year &&
          order.orderDate.month == now.month &&
          order.orderDate.day == now.day;
    }).length;
  }

  double get deliveredSales {
    return orders
        .where((order) => order.status == SupplierOrderStatus.delivered)
        .fold<double>(
          0,
          (sum, order) => sum + order.totalAmount,
        );
  }

  double get monthlyRevenue {
    final now = DateTime.now();

    return orders.where((order) {
      return order.status == SupplierOrderStatus.delivered &&
          order.orderDate.year == now.year &&
          order.orderDate.month == now.month;
    }).fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );
  }

  SupplierDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<SupplierOrderEntity>? orders,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      orders: orders ?? this.orders,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        orders,
        errorMessage,
      ];
}
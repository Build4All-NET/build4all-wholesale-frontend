import 'package:equatable/equatable.dart';

import '../../../domain/entities/low_stock_alert_entity.dart';
import '../../../../orders/domain/entities/supplier_order_entity.dart';

class SupplierDashboardState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<SupplierOrderEntity> orders;
  final List<LowStockAlertEntity> lowStockAlerts;
  final String? errorMessage;

  const SupplierDashboardState({
    required this.isLoading,
    required this.isRefreshing,
    required this.orders,
    required this.lowStockAlerts,
    this.errorMessage,
  });

  factory SupplierDashboardState.initial() {
    return const SupplierDashboardState(
      isLoading: false,
      isRefreshing: false,
      orders: [],
      lowStockAlerts: [],
      errorMessage: null,
    );
  }

  // =========================
  // ORDER STATUS COUNTS
  // =========================

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

  // =========================
  // DATE HELPERS
  // =========================

  bool _isSameDay(DateTime first, DateTime second) {
    final firstLocal = first.toLocal();
    final secondLocal = second.toLocal();

    return firstLocal.year == secondLocal.year &&
        firstLocal.month == secondLocal.month &&
        firstLocal.day == secondLocal.day;
  }

  bool _isSameMonth(DateTime first, DateTime second) {
    final firstLocal = first.toLocal();
    final secondLocal = second.toLocal();

    return firstLocal.year == secondLocal.year &&
        firstLocal.month == secondLocal.month;
  }

  /// This is the date used for financial sales calculations.
  ///
  /// Best case:
  /// - deliveredAt is provided by backend.
  ///
  /// Fallback:
  /// - statusUpdatedAt / updatedAt.
  ///
  /// Last fallback:
  /// - orderDate.
  ///
  /// So if an order was created yesterday but delivered today,
  /// Today's Sales can count it correctly when deliveredAt/statusUpdatedAt is available.
  DateTime _salesDateForOrder(SupplierOrderEntity order) {
    return order.deliveredAt ?? order.statusUpdatedAt ?? order.orderDate;
  }

  // =========================
  // FINANCIAL METRICS
  // =========================

  /// Orders Today = number of orders created today, regardless of status.
  int get totalOrdersToday {
    final now = DateTime.now();

    return orders.where((order) {
      return _isSameDay(order.orderDate, now);
    }).length;
  }

  /// Today's Sales = delivered orders whose delivered/status update date is today.
  ///
  /// This is more professional than using orderDate only.
  /// If backend sends deliveredAt/statusUpdatedAt, it will count orders delivered today,
  /// even if they were created before today.
  double get todaysSales {
    final now = DateTime.now();

    return orders.where((order) {
      if (order.status != SupplierOrderStatus.delivered) return false;

      final salesDate = _salesDateForOrder(order);
      return _isSameDay(salesDate, now);
    }).fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );
  }

  /// Monthly Revenue = delivered orders whose delivered/status update date
  /// is within the current month.
  double get monthlyRevenue {
    final now = DateTime.now();

    return orders.where((order) {
      if (order.status != SupplierOrderStatus.delivered) return false;

      final salesDate = _salesDateForOrder(order);
      return _isSameMonth(salesDate, now);
    }).fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );
  }

  /// Total delivered revenue across all time.
  /// Kept for future dashboard usage.
  double get totalDeliveredRevenue {
    return orders
        .where((order) => order.status == SupplierOrderStatus.delivered)
        .fold<double>(
          0,
          (sum, order) => sum + order.totalAmount,
        );
  }

  SupplierDashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<SupplierOrderEntity>? orders,
    List<LowStockAlertEntity>? lowStockAlerts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      orders: orders ?? this.orders,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        orders,
        lowStockAlerts,
        errorMessage,
      ];
}
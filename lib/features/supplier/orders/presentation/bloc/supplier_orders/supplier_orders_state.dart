import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_order_entity.dart';

class SupplierOrdersState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final String searchQuery;
  final SupplierOrderStatus? selectedStatus;
  final List<SupplierOrderEntity> allOrders;
  final List<SupplierOrderEntity> orders;
  final Map<SupplierOrderStatus, int> statusCounts;
  final String? errorMessage;

  const SupplierOrdersState({
    required this.isLoading,
    required this.isRefreshing,
    required this.searchQuery,
    required this.selectedStatus,
    required this.allOrders,
    required this.orders,
    required this.statusCounts,
    this.errorMessage,
  });

  factory SupplierOrdersState.initial() {
    return const SupplierOrdersState(
      isLoading: false,
      isRefreshing: false,
      searchQuery: '',
      selectedStatus: null,
      allOrders: [],
      orders: [],
      statusCounts: {},
      errorMessage: null,
    );
  }

  SupplierOrdersState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? searchQuery,
    SupplierOrderStatus? selectedStatus,
    bool clearSelectedStatus = false,
    List<SupplierOrderEntity>? allOrders,
    List<SupplierOrderEntity>? orders,
    Map<SupplierOrderStatus, int>? statusCounts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus:
          clearSelectedStatus ? null : selectedStatus ?? this.selectedStatus,
      allOrders: allOrders ?? this.allOrders,
      orders: orders ?? this.orders,
      statusCounts: statusCounts ?? this.statusCounts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  int countForStatus(SupplierOrderStatus status) {
    return statusCounts[status] ?? 0;
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        searchQuery,
        selectedStatus,
        allOrders,
        orders,
        statusCounts,
        errorMessage,
      ];
}
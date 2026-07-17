import '../../domain/entities/retailer_order_entity.dart';
import '../../domain/entities/skipped_reorder_item_entity.dart';

class RetailerOrdersState {
  final bool isLoading;
  final bool isDetailsLoading;
  final List<RetailerOrderEntity> orders;
  final RetailerOrderEntity? selectedOrder;
  final RetailerOrderFilter selectedFilter;
  final String? errorMessage;
  final String? successMessage;
  final List<SkippedReorderItemEntity> skippedReorderItems;

  const RetailerOrdersState({
    required this.isLoading,
    required this.isDetailsLoading,
    required this.orders,
    required this.selectedOrder,
    required this.selectedFilter,
    required this.errorMessage,
    required this.successMessage,
    required this.skippedReorderItems,
  });

  factory RetailerOrdersState.initial() {
    return const RetailerOrdersState(
      isLoading: false,
      isDetailsLoading: false,
      orders: [],
      selectedOrder: null,
      selectedFilter: RetailerOrderFilter.all,
      errorMessage: null,
      successMessage: null,
      skippedReorderItems: [],
    );
  }

  List<RetailerOrderEntity> get filteredOrders {
    switch (selectedFilter) {
      case RetailerOrderFilter.all:
        return orders;
      case RetailerOrderFilter.pending:
        return orders.where((order) => order.isPendingGroup).toList();
      case RetailerOrderFilter.delivered:
        return orders
            .where((order) => order.status == RetailerOrderStatus.delivered)
            .toList();
      case RetailerOrderFilter.cancelled:
        return orders
            .where((order) => order.status == RetailerOrderStatus.cancelled)
            .toList();
    }
  }

  int countForFilter(RetailerOrderFilter filter) {
    switch (filter) {
      case RetailerOrderFilter.all:
        return orders.length;
      case RetailerOrderFilter.pending:
        return orders.where((order) => order.isPendingGroup).length;
      case RetailerOrderFilter.delivered:
        return orders
            .where((order) => order.status == RetailerOrderStatus.delivered)
            .length;
      case RetailerOrderFilter.cancelled:
        return orders
            .where((order) => order.status == RetailerOrderStatus.cancelled)
            .length;
    }
  }

  RetailerOrdersState copyWith({
    bool? isLoading,
    bool? isDetailsLoading,
    List<RetailerOrderEntity>? orders,
    RetailerOrderEntity? selectedOrder,
    bool clearSelectedOrder = false,
    RetailerOrderFilter? selectedFilter,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    List<SkippedReorderItemEntity>? skippedReorderItems,
  }) {
    return RetailerOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      orders: orders ?? this.orders,
      selectedOrder:
          clearSelectedOrder ? null : selectedOrder ?? this.selectedOrder,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
      skippedReorderItems: skippedReorderItems ?? this.skippedReorderItems,
    );
  }
}

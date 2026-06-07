import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/supplier_order_entity.dart';
import '../../../domain/usecases/get_supplier_orders_usecase.dart';
import 'supplier_orders_event.dart';
import 'supplier_orders_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierOrdersBloc
    extends Bloc<SupplierOrdersEvent, SupplierOrdersState> {
  final GetSupplierOrdersUseCase getSupplierOrdersUseCase;

  SupplierOrdersBloc({
    required this.getSupplierOrdersUseCase,
  }) : super(SupplierOrdersState.initial()) {
    on<SupplierOrdersStarted>(_onStarted);
    on<SupplierOrdersRefreshed>(_onRefreshed);
    on<SupplierOrdersSearchChanged>(_onSearchChanged);
    on<SupplierOrdersStatusFilterChanged>(_onStatusFilterChanged);
    on<SupplierOrdersOrderUpdated>(_onOrderUpdated);
  }

  Future<void> _onStarted(
    SupplierOrdersStarted event,
    Emitter<SupplierOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    await _loadOrders(emit, isRefreshing: false);
  }

  Future<void> _onRefreshed(
    SupplierOrdersRefreshed event,
    Emitter<SupplierOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        isRefreshing: true,
        clearError: true,
      ),
    );

    await _loadOrders(emit, isRefreshing: true);
  }

  void _onSearchChanged(
    SupplierOrdersSearchChanged event,
    Emitter<SupplierOrdersState> emit,
  ) {
    final filteredOrders = _applyFilters(
      allOrders: state.allOrders,
      searchQuery: event.query,
      selectedStatus: state.selectedStatus,
    );

    emit(
      state.copyWith(
        searchQuery: event.query,
        orders: filteredOrders,
        clearError: true,
      ),
    );
  }

  void _onStatusFilterChanged(
    SupplierOrdersStatusFilterChanged event,
    Emitter<SupplierOrdersState> emit,
  ) {
    final filteredOrders = _applyFilters(
      allOrders: state.allOrders,
      searchQuery: state.searchQuery,
      selectedStatus: event.status,
    );

    emit(
      state.copyWith(
        selectedStatus: event.status,
        clearSelectedStatus: event.status == null,
        orders: filteredOrders,
        clearError: true,
      ),
    );
  }

  void _onOrderUpdated(
    SupplierOrdersOrderUpdated event,
    Emitter<SupplierOrdersState> emit,
  ) {
    final updatedAllOrders = state.allOrders.map((order) {
      return order.id == event.order.id ? event.order : order;
    }).toList();

    final filteredOrders = _applyFilters(
      allOrders: updatedAllOrders,
      searchQuery: state.searchQuery,
      selectedStatus: state.selectedStatus,
    );

    emit(
      state.copyWith(
        allOrders: updatedAllOrders,
        orders: filteredOrders,
        statusCounts: _buildStatusCounts(updatedAllOrders),
        clearError: true,
      ),
    );
  }

  Future<void> _loadOrders(
    Emitter<SupplierOrdersState> emit, {
    required bool isRefreshing,
  }) async {
    try {
      final orders = await getSupplierOrdersUseCase();

      final filteredOrders = _applyFilters(
        allOrders: orders,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          allOrders: orders,
          orders: filteredOrders,
          statusCounts: _buildStatusCounts(orders),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  List<SupplierOrderEntity> _applyFilters({
    required List<SupplierOrderEntity> allOrders,
    required String searchQuery,
    required SupplierOrderStatus? selectedStatus,
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    return allOrders.where((order) {
      final matchesStatus =
          selectedStatus == null || order.status == selectedStatus;

      final matchesSearch = normalizedQuery.isEmpty ||
          order.orderNumber.toLowerCase().contains(normalizedQuery) ||
          order.retailerName.toLowerCase().contains(normalizedQuery) ||
          order.deliveryAddress.toLowerCase().contains(normalizedQuery) ||
          order.paymentMethod.toLowerCase().contains(normalizedQuery);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  Map<SupplierOrderStatus, int> _buildStatusCounts(
    List<SupplierOrderEntity> orders,
  ) {
    final counts = <SupplierOrderStatus, int>{};

    for (final status in SupplierOrderStatus.values) {
      counts[status] = orders.where((order) => order.status == status).length;
    }

    return counts;
  }
}

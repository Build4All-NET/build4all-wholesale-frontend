import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../domain/entities/retailer_order_entity.dart';
import '../../domain/usecases/cancel_retailer_order_usecase.dart';
import '../../domain/usecases/get_retailer_order_details_usecase.dart';
import '../../domain/usecases/get_retailer_orders_usecase.dart';
import '../../domain/usecases/reorder_retailer_order_usecase.dart';
import 'retailer_orders_state.dart';

class RetailerOrdersCubit extends Cubit<RetailerOrdersState> {
  final GetRetailerOrdersUseCase getRetailerOrdersUseCase;
  final GetRetailerOrderDetailsUseCase getRetailerOrderDetailsUseCase;
  final CancelRetailerOrderUseCase cancelRetailerOrderUseCase;
  final ReorderRetailerOrderUseCase reorderRetailerOrderUseCase;

  RetailerOrdersCubit({
    required this.getRetailerOrdersUseCase,
    required this.getRetailerOrderDetailsUseCase,
    required this.cancelRetailerOrderUseCase,
    required this.reorderRetailerOrderUseCase,
  }) : super(RetailerOrdersState.initial());

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final orders = await getRetailerOrdersUseCase();
      emit(state.copyWith(isLoading: false, orders: orders));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(e)));
    }
  }

  Future<void> refreshOrders() => loadOrders();

  void selectFilter(RetailerOrderFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> loadOrderDetails({required int orderId}) async {
    emit(
      state.copyWith(
        isDetailsLoading: true,
        clearErrorMessage: true,
        clearSelectedOrder: true,
      ),
    );

    try {
      final order = await getRetailerOrderDetailsUseCase(orderId: orderId);
      emit(state.copyWith(isDetailsLoading: false, selectedOrder: order));
    } catch (e) {
      emit(
        state.copyWith(
          isDetailsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> cancelOrder({required int orderId}) async {
    emit(state.copyWith(isDetailsLoading: true, clearErrorMessage: true));

    try {
      final updatedOrder = await cancelRetailerOrderUseCase(orderId: orderId);
      final updatedOrders = state.orders.map((order) {
        return order.id == updatedOrder.id ? updatedOrder : order;
      }).toList();

      emit(
        state.copyWith(
          isDetailsLoading: false,
          orders: updatedOrders,
          selectedOrder: updatedOrder,
          successMessage: 'ORDER_CANCELLED',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDetailsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> reorder({required int orderId}) async {
    emit(state.copyWith(isDetailsLoading: true, clearErrorMessage: true));

    try {
      await reorderRetailerOrderUseCase(orderId: orderId);

      emit(
        state.copyWith(
          isDetailsLoading: false,
          successMessage: 'ORDER_REORDERED',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDetailsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );
  }
}

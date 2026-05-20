import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/supplier_order_entity.dart';
import '../../../domain/usecases/get_supplier_order_details_usecase.dart';
import '../../../domain/usecases/update_supplier_order_status_usecase.dart';
import 'supplier_order_details_event.dart';
import 'supplier_order_details_state.dart';

class SupplierOrderDetailsBloc
    extends Bloc<SupplierOrderDetailsEvent, SupplierOrderDetailsState> {
  final GetSupplierOrderDetailsUseCase getSupplierOrderDetailsUseCase;
  final UpdateSupplierOrderStatusUseCase updateSupplierOrderStatusUseCase;

  SupplierOrderDetailsBloc({
    required this.getSupplierOrderDetailsUseCase,
    required this.updateSupplierOrderStatusUseCase,
  }) : super(SupplierOrderDetailsState.initial()) {
    on<SupplierOrderDetailsStarted>(_onStarted);
    on<SupplierOrderDetailsStatusUpdateRequested>(_onStatusUpdateRequested);
  }

  Future<void> _onStarted(
    SupplierOrderDetailsStarted event,
    Emitter<SupplierOrderDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: event.initialOrder == null,
        order: event.initialOrder,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final order = await getSupplierOrderDetailsUseCase(
        orderId: event.orderId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          order: order,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onStatusUpdateRequested(
    SupplierOrderDetailsStatusUpdateRequested event,
    Emitter<SupplierOrderDetailsState> emit,
  ) async {
    final currentOrder = state.order;

    if (currentOrder == null || state.isUpdating) return;

    emit(
      state.copyWith(
        isUpdating: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final updatedOrder = await updateSupplierOrderStatusUseCase(
        orderId: currentOrder.id,
        status: event.status,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          order: updatedOrder,
          successMessage: 'orderStatusUpdated',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          clearSuccess: true,
        ),
      );
    }
  }
}
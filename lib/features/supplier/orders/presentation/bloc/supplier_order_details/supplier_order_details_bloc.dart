import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/supplier_order_entity.dart';
import '../../../domain/usecases/get_supplier_order_details_usecase.dart';
import '../../../domain/usecases/update_supplier_order_status_usecase.dart';
import '../../../../payment/domain/usecases/get_supplier_order_payment_usecase.dart';
import '../../../../payment/domain/usecases/mark_supplier_cash_payment_paid_usecase.dart';
import 'supplier_order_details_event.dart';
import 'supplier_order_details_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierOrderDetailsBloc
    extends Bloc<SupplierOrderDetailsEvent, SupplierOrderDetailsState> {
  final GetSupplierOrderDetailsUseCase getSupplierOrderDetailsUseCase;
  final UpdateSupplierOrderStatusUseCase updateSupplierOrderStatusUseCase;
  final GetSupplierOrderPaymentUseCase getSupplierOrderPaymentUseCase;
  final MarkSupplierCashPaymentPaidUseCase markSupplierCashPaymentPaidUseCase;

  SupplierOrderDetailsBloc({
    required this.getSupplierOrderDetailsUseCase,
    required this.updateSupplierOrderStatusUseCase,
    required this.getSupplierOrderPaymentUseCase,
    required this.markSupplierCashPaymentPaidUseCase,
  }) : super(SupplierOrderDetailsState.initial()) {
    on<SupplierOrderDetailsStarted>(_onStarted);
    on<SupplierOrderDetailsStatusUpdateRequested>(_onStatusUpdateRequested);
    on<SupplierOrderDetailsPaymentRefreshRequested>(_onPaymentRefreshRequested);
    on<SupplierOrderDetailsMarkCashPaidRequested>(_onMarkCashPaidRequested);
  }

  Future<void> _onStarted(
    SupplierOrderDetailsStarted event,
    Emitter<SupplierOrderDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: event.initialOrder == null,
        isPaymentLoading: true,
        order: event.initialOrder,
        clearError: true,
        clearSuccess: true,
        clearPayment: true,
      ),
    );

    SupplierOrderEntity? loadedOrder = event.initialOrder;

    try {
      loadedOrder = await getSupplierOrderDetailsUseCase(
        orderId: event.orderId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          order: loadedOrder,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
          clearSuccess: true,
        ),
      );
    }

    await _loadPayment(event.orderId, emit, showErrors: false);
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
          errorMessage: AppErrorMapper.toMessage(e),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onPaymentRefreshRequested(
    SupplierOrderDetailsPaymentRefreshRequested event,
    Emitter<SupplierOrderDetailsState> emit,
  ) async {
    final currentOrder = state.order;
    if (currentOrder == null || state.isPaymentLoading) return;
    await _loadPayment(currentOrder.id, emit, showErrors: true);
  }

  Future<void> _onMarkCashPaidRequested(
    SupplierOrderDetailsMarkCashPaidRequested event,
    Emitter<SupplierOrderDetailsState> emit,
  ) async {
    final currentOrder = state.order;
    if (currentOrder == null || state.isPaymentUpdating) return;

    emit(
      state.copyWith(
        isPaymentUpdating: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final payment = await markSupplierCashPaymentPaidUseCase(
        orderId: currentOrder.id,
      );

      emit(
        state.copyWith(
          isPaymentUpdating: false,
          payment: payment,
          successMessage: 'cashPaymentMarkedPaid',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPaymentUpdating: false,
          errorMessage: AppErrorMapper.toMessage(e),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _loadPayment(
    int orderId,
    Emitter<SupplierOrderDetailsState> emit, {
    required bool showErrors,
  }) async {
    emit(
      state.copyWith(
        isPaymentLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final payment = await getSupplierOrderPaymentUseCase(orderId: orderId);

      emit(
        state.copyWith(
          isPaymentLoading: false,
          payment: payment,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPaymentLoading: false,
          errorMessage: showErrors
              ? AppErrorMapper.toMessage(e)
              : null,
          clearError: !showErrors,
          clearSuccess: true,
        ),
      );
    }
  }
}

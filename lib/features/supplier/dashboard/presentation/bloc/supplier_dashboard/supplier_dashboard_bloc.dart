import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dashboard/domain/usecases/get_supplier_low_stock_alerts_usecase.dart';
import '../../../../orders/domain/usecases/get_supplier_orders_usecase.dart';
import '../../../../profile/domain/usecases/get_supplier_profile_display_usecase.dart';
import 'supplier_dashboard_event.dart';
import 'supplier_dashboard_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierDashboardBloc
    extends Bloc<SupplierDashboardEvent, SupplierDashboardState> {
  final GetSupplierOrdersUseCase getSupplierOrdersUseCase;
  final GetSupplierLowStockAlertsUseCase getSupplierLowStockAlertsUseCase;
  final GetSupplierProfileDisplayUseCase getSupplierProfileDisplayUseCase;

  SupplierDashboardBloc({
    required this.getSupplierOrdersUseCase,
    required this.getSupplierLowStockAlertsUseCase,
    required this.getSupplierProfileDisplayUseCase,
  }) : super(SupplierDashboardState.initial()) {
    on<SupplierDashboardStarted>(_onStarted);
    on<SupplierDashboardRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(
    SupplierDashboardStarted event,
    Emitter<SupplierDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshed(
    SupplierDashboardRefreshed event,
    Emitter<SupplierDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        isRefreshing: true,
        clearError: true,
      ),
    );

    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(
    Emitter<SupplierDashboardState> emit,
  ) async {
    try {
      final results = await Future.wait<dynamic>([
        getSupplierOrdersUseCase(),
        getSupplierLowStockAlertsUseCase(),
        getSupplierProfileDisplayUseCase(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          orders: results[0],
          lowStockAlerts: results[1],
          supplierDisplayName: results[2].fullName,
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
}

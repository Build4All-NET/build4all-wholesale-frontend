import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../dashboard/domain/usecases/get_supplier_low_stock_alerts_usecase.dart';

import '../../../../orders/domain/usecases/get_supplier_orders_usecase.dart';

import 'supplier_dashboard_event.dart';

import 'supplier_dashboard_state.dart';


class SupplierDashboardBloc

    extends Bloc<SupplierDashboardEvent, SupplierDashboardState> {

  final GetSupplierOrdersUseCase getSupplierOrdersUseCase;

  final GetSupplierLowStockAlertsUseCase getSupplierLowStockAlertsUseCase;


  SupplierDashboardBloc({

    required this.getSupplierOrdersUseCase,

    required this.getSupplierLowStockAlertsUseCase,

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

      final orders = await getSupplierOrdersUseCase();

      final lowStockAlerts = await getSupplierLowStockAlertsUseCase();


      emit(

        state.copyWith(

          isLoading: false,

          isRefreshing: false,

          orders: orders,

          lowStockAlerts: lowStockAlerts,

          clearError: true,

        ),

      );

    } catch (e) {

      emit(

        state.copyWith(

          isLoading: false,

          isRefreshing: false,

          errorMessage: e.toString().replaceFirst('Exception: ', ''),

        ),

      );

    }

  }

}


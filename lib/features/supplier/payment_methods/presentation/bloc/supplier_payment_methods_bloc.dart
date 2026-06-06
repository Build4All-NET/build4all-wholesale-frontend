import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/supplier_payment_method_entity.dart';
import '../../domain/usecases/get_supplier_payment_methods_usecase.dart';
import '../../domain/usecases/save_supplier_payment_method_usecase.dart';
import 'supplier_payment_methods_event.dart';
import 'supplier_payment_methods_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierPaymentMethodsBloc
    extends Bloc<SupplierPaymentMethodsEvent, SupplierPaymentMethodsState> {
  final GetSupplierPaymentMethodsUsecase getPaymentMethods;
  final SaveSupplierPaymentMethodUsecase savePaymentMethod;

  SupplierPaymentMethodsBloc({
    required this.getPaymentMethods,
    required this.savePaymentMethod,
  }) : super(SupplierPaymentMethodsState.initial()) {
    on<SupplierPaymentMethodsStarted>(_onLoad);
    on<SupplierPaymentMethodsRefreshed>(_onLoad);
    on<SupplierPaymentMethodToggled>(_onToggle);
  }

  Future<void> _onLoad(
    SupplierPaymentMethodsEvent event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    try {
      final methods = await getPaymentMethods();
      emit(state.copyWith(isLoading: false, methods: methods));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(e)));
    }
  }

  Future<void> _onToggle(
    SupplierPaymentMethodToggled event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    final code = event.methodCode.toUpperCase().trim();
    final current = state.methods.where((item) => item.code.toUpperCase() == code).toList();

    if (current.isEmpty) {
      emit(state.copyWith(errorMessage: 'Payment method not found.'));
      return;
    }

    final selected = current.first;
    if (!selected.supportedNow && event.enabled) {
      emit(state.copyWith(
        errorMessage:
            'This online payment method needs credentials and checkout integration. Keep it disabled for now.',
      ));
      return;
    }

    emit(state.copyWith(
      savingMethodCode: code,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    try {
      final updated = await savePaymentMethod(
        methodCode: code,
        enabled: event.enabled,
        configValues: const {},
      );

      final updatedMethods = state.methods.map((method) {
        return method.code.toUpperCase() == code ? updated : method;
      }).toList();

      emit(state.copyWith(
        methods: updatedMethods,
        clearSavingMethodCode: true,
        successMessage: event.enabled
            ? '${updated.displayName} enabled successfully.'
            : '${updated.displayName} disabled successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(
        clearSavingMethodCode: true,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }
}

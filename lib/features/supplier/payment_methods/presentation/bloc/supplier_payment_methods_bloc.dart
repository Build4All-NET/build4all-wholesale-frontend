import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/supplier_payment_method_entity.dart';
import '../../domain/usecases/get_supplier_payment_methods_usecase.dart';
import '../../domain/usecases/save_supplier_payment_method_usecase.dart';
import '../../domain/usecases/test_supplier_payment_method_usecase.dart';
import 'supplier_payment_methods_event.dart';
import 'supplier_payment_methods_state.dart';
import '../../../../../core/utils/app_error_mapper.dart';

class SupplierPaymentMethodsBloc
    extends Bloc<SupplierPaymentMethodsEvent, SupplierPaymentMethodsState> {
  final GetSupplierPaymentMethodsUsecase getPaymentMethods;
  final SaveSupplierPaymentMethodUsecase savePaymentMethod;
  final TestSupplierPaymentMethodUsecase testPaymentMethod;

  SupplierPaymentMethodsBloc({
    required this.getPaymentMethods,
    required this.savePaymentMethod,
    required this.testPaymentMethod,
  }) : super(SupplierPaymentMethodsState.initial()) {
    on<SupplierPaymentMethodsStarted>(_onLoad);
    on<SupplierPaymentMethodsRefreshed>(_onLoad);
    on<SupplierPaymentMethodToggled>(_onToggle);
    on<SupplierPaymentMethodConfigSaved>(_onConfigSaved);
    on<SupplierPaymentMethodTested>(_onTest);
  }

  // ───────────────────────────────────────────────────────── load ──

  Future<void> _onLoad(
    SupplierPaymentMethodsEvent event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearTestResult: true,
    ));

    try {
      final methods = await getPaymentMethods();
      emit(state.copyWith(isLoading: false, methods: methods));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(e)));
    }
  }

  // ───────────────────────────────────────────────────────── toggle ──
  // Used for CASH (simple enable/disable, no credentials needed).

  Future<void> _onToggle(
    SupplierPaymentMethodToggled event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    final code = event.methodCode.toUpperCase().trim();

    final selected = state.methods
        .where((m) => m.code.toUpperCase() == code)
        .firstOrNull;

    if (selected == null) {
      emit(state.copyWith(errorMessage: 'Payment method not found.'));
      return;
    }

    // Methods that require credentials cannot be toggled directly.
    if (selected.requiresCredentials) {
      emit(state.copyWith(
        errorMessage:
            '${selected.displayName} requires credentials. '
            'Use the Configure button to set it up first.',
      ));
      return;
    }

    emit(state.copyWith(
      savingMethodCode: code,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearTestResult: true,
    ));

    try {
      final updated = await savePaymentMethod(
        methodCode: code,
        enabled: event.enabled,
        configValues: const {},
      );

      emit(state.copyWith(
        methods: _replaceMethod(state.methods, code, updated),
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

  // ───────────────────────────────────────────────────────── config save ──
  // Used for STRIPE and any future method that needs credentials.

  Future<void> _onConfigSaved(
    SupplierPaymentMethodConfigSaved event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    final code = event.methodCode.toUpperCase().trim();

    emit(state.copyWith(
      savingMethodCode: code,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearTestResult: true,
    ));

    try {
      final updated = await savePaymentMethod(
        methodCode: code,
        enabled: event.enabled,
        configValues: event.configValues,
      );

      emit(state.copyWith(
        methods: _replaceMethod(state.methods, code, updated),
        clearSavingMethodCode: true,
        successMessage: '${updated.displayName} configuration saved successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(
        clearSavingMethodCode: true,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  // ───────────────────────────────────────────────────────── test ──

  Future<void> _onTest(
    SupplierPaymentMethodTested event,
    Emitter<SupplierPaymentMethodsState> emit,
  ) async {
    final code = event.methodCode.toUpperCase().trim();

    emit(state.copyWith(
      testingMethodCode: code,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearTestResult: true,
    ));

    try {
      final result = await testPaymentMethod(methodCode: code);

      emit(state.copyWith(
        clearTestingMethodCode: true,
        testResultMethodCode: code,
        testResultSuccess: result.success,
        testResultMessage: result.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        clearTestingMethodCode: true,
        testResultMethodCode: code,
        testResultSuccess: false,
        testResultMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  // ─────────────────────────────────────────────────────────── util ──

  List<SupplierPaymentMethodEntity> _replaceMethod(
    List<SupplierPaymentMethodEntity> methods,
    String code,
    SupplierPaymentMethodEntity updated,
  ) {
    return methods.map((m) {
      return m.code.toUpperCase() == code ? updated : m;
    }).toList();
  }
}
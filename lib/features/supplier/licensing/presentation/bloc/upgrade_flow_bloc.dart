import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';
import '../../domain/usecases/licensing_usecases.dart';
import 'upgrade_flow_event.dart';
import 'upgrade_flow_state.dart';

class UpgradeFlowBloc extends Bloc<UpgradeFlowEvent, UpgradeFlowState> {
  final GetAvailableUpgradePlans getPlansUc;
  final GetAvailablePaymentMethods getPaymentMethodsUc;
  final InitiateUpgradePayment initiatePaymentUc;
  final ConfirmUpgradePayment confirmPaymentUc;
  final RefreshOwnerSubscription refreshSubscriptionUc;

  UpgradeFlowBloc({
    required this.getPlansUc,
    required this.getPaymentMethodsUc,
    required this.initiatePaymentUc,
    required this.confirmPaymentUc,
    required this.refreshSubscriptionUc,
  }) : super(UpgradeFlowState.initial()) {
    on<UpgradePlansRequested>(_onPlansRequested);
    on<UpgradePlanSelected>(_onPlanSelected);
    on<UpgradeBillingCycleSelected>(_onCycleSelected);
    on<UpgradePaymentMethodSelected>(_onPaymentMethodSelected);
    on<UpgradePaymentRequested>(_onPaymentRequested);
    on<UpgradePaymentSucceeded>(_onPaymentSucceeded);
    on<UpgradePaymentFailed>(_onPaymentFailed);
    on<UpgradeFlowReset>(_onReset);
    on<UpgradeFlowMessagesCleared>(_onMessagesCleared);
  }

  Future<void> _onPlansRequested(
    UpgradePlansRequested event,
    Emitter<UpgradeFlowState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: UpgradeFlowStatus.loadingPlans,
        errorMessage: null,
        lastMessage: null,
      ));

      final plans = await getPlansUc();
      final methods = await getPaymentMethodsUc();

      final autoSelected =
          methods.length == 1 ? methods.first.selectionCode : null;

      emit(state.copyWith(
        status: UpgradeFlowStatus.plansReady,
        plans: plans,
        availablePaymentMethods: methods,
        selectedPaymentMethodCode: autoSelected,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UpgradeFlowStatus.plansError,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  void _onPlanSelected(UpgradePlanSelected event, Emitter<UpgradeFlowState> emit) {
    emit(state.copyWith(selectedPlan: event.planCode));
  }

  void _onCycleSelected(
      UpgradeBillingCycleSelected event, Emitter<UpgradeFlowState> emit) {
    emit(state.copyWith(billingCycle: event.cycle));
  }

  void _onPaymentMethodSelected(
      UpgradePaymentMethodSelected event, Emitter<UpgradeFlowState> emit) {
    emit(state.copyWith(selectedPaymentMethodCode: event.code));
  }

  Future<void> _onPaymentRequested(
    UpgradePaymentRequested event,
    Emitter<UpgradeFlowState> emit,
  ) async {
    final plan = state.selectedPlan;
    if (plan == null) {
      emit(state.copyWith(
          status: UpgradeFlowStatus.error, errorMessage: 'SELECT_PLAN'));
      return;
    }
    final methodCode = state.selectedPaymentMethodCode;
    if (methodCode == null || methodCode.isEmpty) {
      emit(state.copyWith(
          status: UpgradeFlowStatus.error, errorMessage: 'SELECT_METHOD'));
      return;
    }

    try {
      emit(state.copyWith(
        status: UpgradeFlowStatus.initiatingPayment,
        errorMessage: null,
        lastMessage: null,
        clearPaymentIntent: true,
        clearPaymentReceipt: true,
        clearConfirmedAccess: true,
      ));

      final intent = await initiatePaymentUc(
        InitiateUpgradePaymentParams(
          planCode: plan,
          billingCycle: state.billingCycle,
          paymentMethodCode: methodCode,
        ),
      );

      // Stripe and manual providers both move to awaitingPayment; the sheet
      // decides what to do based on intent.provider.
      emit(state.copyWith(
        status: UpgradeFlowStatus.awaitingPayment,
        paymentIntent: intent,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UpgradeFlowStatus.error,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  Future<void> _onPaymentSucceeded(
    UpgradePaymentSucceeded event,
    Emitter<UpgradeFlowState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UpgradeFlowStatus.confirmingPayment));

      final receipt =
          await confirmPaymentUc(paymentIntentId: event.paymentIntentId);

      emit(state.copyWith(
        status: UpgradeFlowStatus.success,
        paymentReceipt: receipt,
        confirmedAccess: receipt.access,
        lastMessage: 'upgrade_payment_success',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UpgradeFlowStatus.error,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  void _onPaymentFailed(
      UpgradePaymentFailed event, Emitter<UpgradeFlowState> emit) {
    emit(state.copyWith(
        status: UpgradeFlowStatus.error, errorMessage: event.message));
  }

  void _onReset(UpgradeFlowReset event, Emitter<UpgradeFlowState> emit) {
    emit(UpgradeFlowState.initial());
  }

  void _onMessagesCleared(
      UpgradeFlowMessagesCleared event, Emitter<UpgradeFlowState> emit) {
    emit(state.copyWith(errorMessage: null, lastMessage: null));
  }
}

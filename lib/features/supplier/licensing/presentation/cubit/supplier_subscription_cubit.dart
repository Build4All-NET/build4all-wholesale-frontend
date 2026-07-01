import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';
import '../../domain/usecases/licensing_usecases.dart';
import 'supplier_subscription_state.dart';

class SupplierSubscriptionCubit extends Cubit<SupplierSubscriptionState> {
  final GetCurrentLicensePlan getCurrentLicensePlanUc;

  SupplierSubscriptionCubit({required this.getCurrentLicensePlanUc})
      : super(SupplierSubscriptionState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final access = await getCurrentLicensePlanUc();
      emit(state.copyWith(isLoading: false, access: access));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: AppErrorMapper.toMessage(e),
      ));
    }
  }

  Future<void> refresh() => load();
}

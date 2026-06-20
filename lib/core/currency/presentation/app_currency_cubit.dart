import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/app_config.dart';
import '../app_currency_runtime_store.dart';
import '../domain/app_currency.dart';
import '../domain/get_project_currency_usecase.dart';
import 'app_currency_state.dart';

class AppCurrencyCubit extends Cubit<AppCurrencyState> {
  final GetProjectCurrencyUseCase getProjectCurrencyUseCase;

  AppCurrencyCubit({required this.getProjectCurrencyUseCase})
      : super(const AppCurrencyState.initial());

  bool _loadStarted = false;

  Future<void> loadConfiguredCurrency({bool force = false}) async {
    if (_loadStarted && !force) return;

    final id = int.tryParse(AppConfig.currencyId.trim());

    if (id == null || id <= 0) {
      _loadStarted = true;
      AppCurrencyRuntimeStore.update(AppCurrency.fallback);
      emit(
        state.copyWith(
          status: AppCurrencyStatus.failure,
          currency: AppCurrency.fallback,
          errorMessage: 'CURRENCY_ID is missing from app config',
        ),
      );
      return;
    }

    _loadStarted = true;
    emit(state.copyWith(status: AppCurrencyStatus.loading, clearError: true));

    try {
      final loaded = await getProjectCurrencyUseCase(id);
      final normalized = _normalize(loaded, id);

      AppCurrencyRuntimeStore.update(normalized);
      emit(
        state.copyWith(
          status: AppCurrencyStatus.loaded,
          currency: normalized,
          clearError: true,
        ),
      );
    } catch (e) {
      AppCurrencyRuntimeStore.update(AppCurrency.fallback);
      emit(
        state.copyWith(
          status: AppCurrencyStatus.failure,
          currency: AppCurrency.fallback,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  AppCurrency _normalize(AppCurrency currency, int requestedId) {
    final code = currency.code.trim().toUpperCase();
    final symbol = currency.symbol.trim();

    if (code.isEmpty && symbol.isEmpty) {
      return AppCurrency.fallback;
    }

    return AppCurrency(
      id: currency.id == 0 ? requestedId : currency.id,
      type: currency.type.trim().isEmpty ? code : currency.type.trim(),
      code: code.isEmpty ? AppCurrency.fallback.code : code,
      symbol: symbol.isEmpty ? code : symbol,
    );
  }
}

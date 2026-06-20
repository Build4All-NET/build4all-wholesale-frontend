import 'package:equatable/equatable.dart';

import '../domain/app_currency.dart';

enum AppCurrencyStatus { initial, loading, loaded, failure }

class AppCurrencyState extends Equatable {
  final AppCurrencyStatus status;
  final AppCurrency currency;
  final String? errorMessage;

  const AppCurrencyState({
    required this.status,
    required this.currency,
    this.errorMessage,
  });

  const AppCurrencyState.initial()
      : status = AppCurrencyStatus.initial,
        currency = AppCurrency.fallback,
        errorMessage = null;

  AppCurrencyState copyWith({
    AppCurrencyStatus? status,
    AppCurrency? currency,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppCurrencyState(
      status: status ?? this.status,
      currency: currency ?? this.currency,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currency, errorMessage];
}

import 'domain/app_currency.dart';

class AppCurrencyRuntimeStore {
  static AppCurrency _currency = AppCurrency.fallback;

  static AppCurrency get currency => _currency;

  static String get code {
    final value = _currency.code.trim();
    return value.isEmpty ? AppCurrency.fallback.code : value.toUpperCase();
  }

  static String get symbol {
    final value = _currency.symbol.trim();
    return value.isEmpty ? AppCurrency.fallback.symbol : value;
  }

  static void update(AppCurrency currency) {
    _currency = currency;
  }
}

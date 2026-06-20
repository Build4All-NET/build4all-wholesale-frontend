import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'app_currency_runtime_store.dart';
import 'domain/app_currency.dart';
import 'presentation/app_currency_cubit.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(
    BuildContext context,
    num? amount, {
    String? fallbackSymbol,
    int decimalDigits = 2,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = _currencyOf(context);
    final symbol = _cleanSymbol(currency.symbol, fallbackSymbol);

    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount ?? 0);
  }

  static String formatCompact(
    BuildContext context,
    num? amount, {
    String? fallbackSymbol,
  }) {
    final value = amount ?? 0;
    final currency = _currencyOf(context);
    final symbol = _cleanSymbol(currency.symbol, fallbackSymbol);
    final formattedNumber = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    return '$symbol$formattedNumber';
  }

  static String code(BuildContext context, {String fallback = 'USD'}) {
    final code = _currencyOf(context).code.trim();
    return code.isEmpty ? fallback : code.toUpperCase();
  }

  static String symbol(BuildContext context, {String fallback = r'$'}) {
    return _cleanSymbol(_currencyOf(context).symbol, fallback);
  }

  static String runtimeCode({String fallback = 'USD'}) {
    final code = AppCurrencyRuntimeStore.code.trim();
    return code.isEmpty ? fallback : code.toUpperCase();
  }

  static AppCurrency _currencyOf(BuildContext context) {
    try {
      return context.watch<AppCurrencyCubit>().state.currency;
    } catch (_) {
      return AppCurrencyRuntimeStore.currency;
    }
  }

  static String _cleanSymbol(String? symbol, String? fallbackSymbol) {
    final clean = symbol?.trim();
    if (clean != null && clean.isNotEmpty) return clean;

    final fallback = fallbackSymbol?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;

    return AppCurrency.fallback.symbol;
  }
}

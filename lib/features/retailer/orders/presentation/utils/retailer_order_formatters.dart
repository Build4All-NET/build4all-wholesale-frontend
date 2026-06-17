import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatRetailerOrderCurrency(BuildContext context, double amount) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.currency(locale: locale, symbol: r'$').format(amount);
}

String formatRetailerOrderDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(date);
}

String formatRetailerOrderDateTime(BuildContext context, DateTime? date) {
  if (date == null) return '';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_jm().format(date);
}

String formatRetailerOrderReference(String rawOrderNumber, int orderId) {
  final raw = rawOrderNumber.trim();
  if (raw.isEmpty) {
    return 'ORD-${orderId.toString().padLeft(4, '0')}';
  }

  final normalized = raw.toUpperCase();

  // Old backend references were generated as ORD + timestamp, for example
  // ORD-1781534763677. They are unique but too long for mobile cards.
  final oldTimestampMatch = RegExp(r'^ORD[-_]?\d{10,}$').hasMatch(normalized);
  if (oldTimestampMatch) {
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = digits.length <= 4 ? digits : digits.substring(digits.length - 4);
    return 'ORD-$suffix';
  }

  // Newer readable references may be ORD-20260615-134500-1234.
  // On list cards we show the final short part to keep the UI clean.
  final parts = normalized.split('-').where((part) => part.trim().isNotEmpty).toList();
  if (parts.length >= 3 && parts.first == 'ORD') {
    final last = parts.last;
    if (last.length <= 6) {
      return 'ORD-$last';
    }
  }

  return raw;
}

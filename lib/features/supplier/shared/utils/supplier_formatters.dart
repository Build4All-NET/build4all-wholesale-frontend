import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/currency_formatter.dart';

String supplierLocaleName(BuildContext context) {
  return Localizations.localeOf(context).toLanguageTag();
}

String formatSupplierCurrency(BuildContext context, num? amount) {
  return CurrencyFormatter.format(context, amount);
}

String formatSupplierCompactCurrency(BuildContext context, num? amount) {
  return CurrencyFormatter.formatCompact(context, amount);
}

String formatSupplierNumber(BuildContext context, num value) {
  return NumberFormat.decimalPattern(supplierLocaleName(context)).format(value);
}

String formatSupplierShortDate(BuildContext context, DateTime date) {
  return DateFormat.yMMMd(supplierLocaleName(context)).format(date);
}

String formatSupplierCompactDateTime(BuildContext context, DateTime date) {
  return DateFormat.yMMMd(supplierLocaleName(context)).add_jm().format(date);
}

String formatSupplierFullDateTime(BuildContext context, DateTime date) {
  return DateFormat.yMMMMd(supplierLocaleName(context)).add_jm().format(date);
}


String formatSupplierOrderReference(String rawOrderNumber, int orderId) {
  final raw = rawOrderNumber.trim();
  if (raw.isEmpty) {
    return 'ORD-${orderId.toString().padLeft(4, '0')}';
  }

  final normalized = raw.toUpperCase();

  // Old backend references were generated using the current timestamp,
  // for example ORD-1781534763677. They are unique but too long for cards.
  final oldTimestampMatch = RegExp(r'^ORD[-_]?\d{10,}$').hasMatch(normalized);
  if (oldTimestampMatch) {
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = digits.length <= 4 ? digits : digits.substring(digits.length - 4);
    return 'ORD-$suffix';
  }

  // New backend references can be long, for example:
  // ORD-20260622143950-62B87E or ORD-20260615-134500-3677.
  // Supplier and Retailer screens should show the same short mobile-friendly
  // reference by keeping only the final unique segment.
  final parts = normalized
      .split('-')
      .where((part) => part.trim().isNotEmpty)
      .toList();
  if (parts.length >= 3 && parts.first == 'ORD') {
    final last = parts.last.trim();
    if (last.isNotEmpty && last.length <= 8) {
      return 'ORD-$last';
    }
  }

  return raw;
}

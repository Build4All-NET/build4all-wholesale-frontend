import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String supplierLocaleName(BuildContext context) {
  return Localizations.localeOf(context).toLanguageTag();
}

String formatSupplierCurrency(BuildContext context, double amount) {
  return NumberFormat.currency(
    locale: supplierLocaleName(context),
    symbol: r'$ ',
    decimalDigits: 2,
  ).format(amount);
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

  // New readable backend references may be ORD-20260615-134500-3677.
  // For mobile screens, keep the final unique part visible and clean.
  final parts = normalized
      .split('-')
      .where((part) => part.trim().isNotEmpty)
      .toList();
  if (parts.length >= 4 &&
      parts.first == 'ORD' &&
      RegExp(r'^\d{8}$').hasMatch(parts[1]) &&
      RegExp(r'^\d{6}$').hasMatch(parts[2])) {
    return 'ORD-${parts.last}';
  }

  return raw;
}

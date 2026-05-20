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

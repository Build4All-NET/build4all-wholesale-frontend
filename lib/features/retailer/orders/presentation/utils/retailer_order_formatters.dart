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

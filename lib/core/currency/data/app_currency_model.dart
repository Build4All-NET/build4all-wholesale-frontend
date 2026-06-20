import '../domain/app_currency.dart';

class AppCurrencyModel extends AppCurrency {
  const AppCurrencyModel({
    required super.id,
    required super.type,
    required super.code,
    required super.symbol,
  });

  factory AppCurrencyModel.fromJson(Map<String, dynamic> json) {
    return AppCurrencyModel(
      id: _toInt(json['id'] ?? json['currencyId'] ?? json['currency_id']),
      type: (json['currencyType'] ?? json['type'] ?? '').toString(),
      code: (json['code'] ?? '').toString().toUpperCase(),
      symbol: (json['symbol'] ?? '').toString(),
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

import 'package:equatable/equatable.dart';

class AppCurrency extends Equatable {
  final int id;
  final String type;
  final String code;
  final String symbol;

  const AppCurrency({
    required this.id,
    required this.type,
    required this.code,
    required this.symbol,
  });

  bool get hasSymbol => symbol.trim().isNotEmpty;
  bool get hasCode => code.trim().isNotEmpty;

  static const fallback = AppCurrency(
    id: 0,
    type: 'US_DOLLAR',
    code: 'USD',
    symbol: r'$',
  );

  @override
  List<Object?> get props => [id, type, code, symbol];
}

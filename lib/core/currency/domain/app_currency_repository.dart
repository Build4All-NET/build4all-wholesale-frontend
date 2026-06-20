import 'app_currency.dart';

abstract class AppCurrencyRepository {
  Future<AppCurrency> getCurrencyById(int id);
}

import 'app_currency.dart';
import 'app_currency_repository.dart';

class GetProjectCurrencyUseCase {
  final AppCurrencyRepository repository;

  GetProjectCurrencyUseCase(this.repository);

  Future<AppCurrency> call(int id) {
    return repository.getCurrencyById(id);
  }
}

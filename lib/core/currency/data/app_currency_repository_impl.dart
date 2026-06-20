import '../domain/app_currency.dart';
import '../domain/app_currency_repository.dart';
import 'app_currency_api_service.dart';

class AppCurrencyRepositoryImpl implements AppCurrencyRepository {
  final AppCurrencyApiService apiService;

  AppCurrencyRepositoryImpl({required this.apiService});

  @override
  Future<AppCurrency> getCurrencyById(int id) {
    return apiService.getCurrencyById(id);
  }
}


import '../../domain/entities/low_stock_alert_entity.dart';

import '../../domain/repositories/supplier_dashboard_repository.dart';

import '../services/supplier_dashboard_api_service.dart';


class SupplierDashboardRepositoryImpl implements SupplierDashboardRepository {

  final SupplierDashboardApiService apiService;


  SupplierDashboardRepositoryImpl({

    required this.apiService,

  });


  @override

  Future<List<LowStockAlertEntity>> getLowStockAlerts() {

    return apiService.getLowStockAlerts();

  }

}


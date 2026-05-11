import '../entities/low_stock_alert_entity.dart';

import '../repositories/supplier_dashboard_repository.dart';


class GetSupplierLowStockAlertsUseCase {

  final SupplierDashboardRepository repository;


  GetSupplierLowStockAlertsUseCase(this.repository);


  Future<List<LowStockAlertEntity>> call() {

    return repository.getLowStockAlerts();

  }

}


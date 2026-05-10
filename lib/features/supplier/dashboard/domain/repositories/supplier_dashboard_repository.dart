import '../entities/low_stock_alert_entity.dart';


abstract class SupplierDashboardRepository {

  Future<List<LowStockAlertEntity>> getLowStockAlerts();

}
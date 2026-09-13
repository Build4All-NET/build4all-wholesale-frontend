import '../entities/supplier_statistics_entity.dart';

abstract class SupplierStatisticsRepository {
  /// Audience counts plus the contactable retailer list for the signed-in supplier.
  Future<SupplierStatisticsEntity> getStatistics();
}

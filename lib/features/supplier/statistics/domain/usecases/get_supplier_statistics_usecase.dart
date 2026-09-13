import '../entities/supplier_statistics_entity.dart';
import '../repositories/supplier_statistics_repository.dart';

class GetSupplierStatisticsUseCase {
  final SupplierStatisticsRepository repository;

  const GetSupplierStatisticsUseCase(this.repository);

  Future<SupplierStatisticsEntity> call() => repository.getStatistics();
}

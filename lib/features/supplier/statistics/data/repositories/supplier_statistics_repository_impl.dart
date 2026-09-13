import '../../domain/entities/supplier_statistics_entity.dart';
import '../../domain/repositories/supplier_statistics_repository.dart';
import '../services/supplier_statistics_api_service.dart';

class SupplierStatisticsRepositoryImpl implements SupplierStatisticsRepository {
  final SupplierStatisticsApiService apiService;

  const SupplierStatisticsRepositoryImpl({required this.apiService});

  @override
  Future<SupplierStatisticsEntity> getStatistics() => apiService.getStatistics();
}

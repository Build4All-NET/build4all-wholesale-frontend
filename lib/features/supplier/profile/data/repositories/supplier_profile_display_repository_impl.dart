import '../../domain/entities/supplier_profile_display_entity.dart';
import '../../domain/repositories/supplier_profile_display_repository.dart';
import '../services/supplier_profile_display_api_service.dart';

class SupplierProfileDisplayRepositoryImpl
    implements SupplierProfileDisplayRepository {
  final SupplierProfileDisplayApiService apiService;

  SupplierProfileDisplayRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<SupplierProfileDisplayEntity> getSupplierProfile() {
    return apiService.getSupplierProfile();
  }
}

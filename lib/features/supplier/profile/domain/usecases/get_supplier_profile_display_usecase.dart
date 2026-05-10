import '../entities/supplier_profile_display_entity.dart';
import '../repositories/supplier_profile_display_repository.dart';

class GetSupplierProfileDisplayUseCase {
  final SupplierProfileDisplayRepository repository;

  GetSupplierProfileDisplayUseCase(this.repository);

  Future<SupplierProfileDisplayEntity> call() {
    return repository.getSupplierProfile();
  }
}

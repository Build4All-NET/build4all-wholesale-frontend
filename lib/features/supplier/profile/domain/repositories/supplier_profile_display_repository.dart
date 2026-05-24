import '../entities/supplier_profile_display_entity.dart';

abstract class SupplierProfileDisplayRepository {
  Future<SupplierProfileDisplayEntity> getSupplierProfile();
}

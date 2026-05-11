import '../entities/supplier_picked_excel_file_entity.dart';
import '../repositories/supplier_excel_import_repository.dart';

class PickSupplierExcelFileUseCase {
  final SupplierExcelImportRepository repository;

  PickSupplierExcelFileUseCase(this.repository);

  Future<SupplierPickedExcelFileEntity?> call() {
    return repository.pickExcelFile();
  }
}

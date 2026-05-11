import '../entities/supplier_excel_parsed_file_entity.dart';
import '../entities/supplier_picked_excel_file_entity.dart';
import '../repositories/supplier_excel_import_repository.dart';

class ParseSupplierExcelFileUseCase {
  final SupplierExcelImportRepository repository;

  ParseSupplierExcelFileUseCase(this.repository);

  Future<SupplierExcelParsedFileEntity> call({
    required SupplierPickedExcelFileEntity file,
  }) {
    return repository.parseExcelFile(file: file);
  }
}

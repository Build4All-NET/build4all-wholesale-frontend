import '../entities/supplier_excel_parsed_file_entity.dart';
import '../entities/supplier_picked_excel_file_entity.dart';

abstract class SupplierExcelImportRepository {
  Future<SupplierPickedExcelFileEntity?> pickExcelFile();

  Future<SupplierExcelParsedFileEntity> parseExcelFile({
    required SupplierPickedExcelFileEntity file,
  });
}

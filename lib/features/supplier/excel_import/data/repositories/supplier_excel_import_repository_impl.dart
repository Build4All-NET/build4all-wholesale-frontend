import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_picked_excel_file_entity.dart';
import '../../domain/repositories/supplier_excel_import_repository.dart';
import '../services/supplier_excel_reader_service.dart';

class SupplierExcelImportRepositoryImpl implements SupplierExcelImportRepository {
  final SupplierExcelReaderService readerService;

  SupplierExcelImportRepositoryImpl({
    required this.readerService,
  });

  @override
  Future<SupplierPickedExcelFileEntity?> pickExcelFile() {
    return readerService.pickExcelFile();
  }

  @override
  Future<SupplierExcelParsedFileEntity> parseExcelFile({
    required SupplierPickedExcelFileEntity file,
  }) {
    return readerService.parseExcelFile(file: file);
  }
}

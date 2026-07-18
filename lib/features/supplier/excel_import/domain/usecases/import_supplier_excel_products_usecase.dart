import '../../data/services/supplier_excel_import_api_service.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_excel_parsed_file_entity.dart';

/// Imports an already-parsed, already-validated workbook in one request.
/// All per-section find-or-create logic (categories, subcategories,
/// branches, products, inventory, tax rules, shipping methods, coupons,
/// promotions, banners) runs server-side inside a single DB transaction —
/// this class is now just a thin call to that endpoint.
class ImportSupplierExcelProductsUseCase {
  final SupplierExcelImportApiService apiService;

  ImportSupplierExcelProductsUseCase({required this.apiService});

  Future<SupplierExcelImportResultEntity> call({
    required SupplierExcelParsedFileEntity parsedFile,
  }) {
    return apiService.importAll(parsedFile: parsedFile);
  }
}

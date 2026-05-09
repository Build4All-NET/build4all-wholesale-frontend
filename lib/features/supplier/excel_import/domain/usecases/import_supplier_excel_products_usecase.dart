import '../../../products/domain/usecases/create_product_usecase.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_excel_product_row_entity.dart';

class ImportSupplierExcelProductsUseCase {
  final CreateProductUseCase createProductUseCase;

  ImportSupplierExcelProductsUseCase({
    required this.createProductUseCase,
  });

  Future<SupplierExcelImportResultEntity> call({
    required List<SupplierExcelProductRowEntity> rows,
  }) async {
    final validRows = rows.where((row) => row.isValid).toList();
    var importedCount = 0;
    final failedMessages = <String>[];

    for (final row in validRows) {
      try {
        await createProductUseCase(
          name: row.productName,
          description: row.description,
          categoryId: row.categoryId!,
          subCategoryId: row.subCategoryId,
          price: row.price!,
          minimumOrderQuantity: row.minimumOrderQuantity!,
          status: row.status!,
          imagePath: null,
        );
        importedCount++;
      } catch (e) {
        failedMessages.add(
          'Row ${row.rowNumber} (${row.productName}): ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }

    return SupplierExcelImportResultEntity(
      totalRows: validRows.length,
      importedCount: importedCount,
      failedCount: failedMessages.length,
      failedMessages: failedMessages,
    );
  }
}

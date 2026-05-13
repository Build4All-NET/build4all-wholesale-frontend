import 'supplier_excel_product_row_entity.dart';

class SupplierExcelParsedFileEntity {
  final String fileName;
  final List<SupplierExcelProductRowEntity> rows;

  SupplierExcelParsedFileEntity({
    required this.fileName,
    required this.rows,
  });
}

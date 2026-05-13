import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelProductRowModel extends SupplierExcelProductRowEntity {
  SupplierExcelProductRowModel({
    required super.rowNumber,
    required super.productName,
    required super.description,
    required super.categoryName,
    required super.subCategoryName,
    required super.priceText,
    required super.moqText,
    required super.statusText,
  });

  factory SupplierExcelProductRowModel.fromCells({
    required int rowNumber,
    required List<String> cells,
  }) {
    String valueAt(int index) {
      if (index < 0 || index >= cells.length) return '';
      return cells[index].trim();
    }

    return SupplierExcelProductRowModel(
      rowNumber: rowNumber,
      productName: valueAt(0),
      description: valueAt(1),
      categoryName: valueAt(2),
      subCategoryName: valueAt(3),
      priceText: valueAt(4),
      moqText: valueAt(5),
      statusText: valueAt(6),
    );
  }
}

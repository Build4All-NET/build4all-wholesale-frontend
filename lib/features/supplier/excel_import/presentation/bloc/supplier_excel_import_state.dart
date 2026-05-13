import 'package:equatable/equatable.dart';

import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelImportState extends Equatable {
  final bool isPickingOrParsing;
  final bool isImporting;
  final String? fileName;
  final List<SupplierExcelProductRowEntity> rows;
  final List<SupplierCategoryEntity> categories;
  final Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId;
  final List<ProductEntity> existingProducts;
  final String? error;
  final String? successMessage;
  final SupplierExcelImportResultEntity? importResult;

  SupplierExcelImportState({
    required this.isPickingOrParsing,
    required this.isImporting,
    required this.rows,
    this.categories = const [],
    this.subCategoriesByCategoryId = const {},
    this.existingProducts = const [],
    this.fileName,
    this.error,
    this.successMessage,
    this.importResult,
  });

  factory SupplierExcelImportState.initial() {
    return SupplierExcelImportState(
      isPickingOrParsing: false,
      isImporting: false,
      rows: const [],
    );
  }

  int get totalRows => rows.length;
  int get validRowsCount => rows.where((row) => row.isValid).length;
  int get errorRowsCount => rows.where((row) => !row.isValid).length;
  int get warningRowsCount => rows.where((row) => row.hasWarnings).length;
  bool get hasRows => rows.isNotEmpty;
  bool get hasErrors => errorRowsCount > 0;
  bool get hasCatalogErrors => rows.any((row) => row.hasCatalogError);
  bool get canImport => hasRows && validRowsCount > 0 && !isImporting;

  SupplierExcelImportState copyWith({
    bool? isPickingOrParsing,
    bool? isImporting,
    String? fileName,
    List<SupplierExcelProductRowEntity>? rows,
    List<SupplierCategoryEntity>? categories,
    Map<String, List<SupplierSubCategoryEntity>>? subCategoriesByCategoryId,
    List<ProductEntity>? existingProducts,
    String? error,
    String? successMessage,
    SupplierExcelImportResultEntity? importResult,
    bool clearMessages = false,
    bool clearImportResult = false,
    bool clearFile = false,
  }) {
    return SupplierExcelImportState(
      isPickingOrParsing: isPickingOrParsing ?? this.isPickingOrParsing,
      isImporting: isImporting ?? this.isImporting,
      fileName: clearFile ? null : fileName ?? this.fileName,
      rows: rows ?? this.rows,
      categories: categories ?? this.categories,
      subCategoriesByCategoryId:
          subCategoriesByCategoryId ?? this.subCategoriesByCategoryId,
      existingProducts: existingProducts ?? this.existingProducts,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
      importResult:
          clearImportResult ? null : importResult ?? this.importResult,
    );
  }

  @override
  List<Object?> get props => [
        isPickingOrParsing,
        isImporting,
        fileName,
        rows,
        categories,
        subCategoriesByCategoryId,
        existingProducts,
        error,
        successMessage,
        importResult,
      ];
}

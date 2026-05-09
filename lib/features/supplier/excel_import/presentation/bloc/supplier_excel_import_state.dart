import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelImportState extends Equatable {
  final bool isPickingOrParsing;
  final bool isImporting;
  final String? fileName;
  final List<SupplierExcelProductRowEntity> rows;
  final String? error;
  final String? successMessage;
  final SupplierExcelImportResultEntity? importResult;

  const SupplierExcelImportState({
    required this.isPickingOrParsing,
    required this.isImporting,
    required this.rows,
    this.fileName,
    this.error,
    this.successMessage,
    this.importResult,
  });

  factory SupplierExcelImportState.initial() {
    return const SupplierExcelImportState(
      isPickingOrParsing: false,
      isImporting: false,
      rows: [],
    );
  }

  int get totalRows => rows.length;
  int get validRowsCount => rows.where((row) => row.isValid).length;
  int get errorRowsCount => rows.where((row) => !row.isValid).length;
  int get warningRowsCount => rows.where((row) => row.hasWarnings).length;
  bool get hasRows => rows.isNotEmpty;
  bool get canImport => hasRows && validRowsCount > 0 && !isImporting;

  SupplierExcelImportState copyWith({
    bool? isPickingOrParsing,
    bool? isImporting,
    String? fileName,
    List<SupplierExcelProductRowEntity>? rows,
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
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
      importResult: clearImportResult ? null : importResult ?? this.importResult,
    );
  }

  @override
  List<Object?> get props => [
        isPickingOrParsing,
        isImporting,
        fileName,
        rows,
        error,
        successMessage,
        importResult,
      ];
}

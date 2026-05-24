import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_excel_section.dart';

class SupplierExcelImportState extends Equatable {
  final bool isDownloadingTemplate;
  final bool isPickingOrParsing;
  final bool isImporting;
  final SupplierExcelParsedFileEntity? parsedFile;
  final String? error;
  final String? successMessage;
  final String? templateSavePath;
  final SupplierExcelImportResultEntity? importResult;

  const SupplierExcelImportState({
    required this.isDownloadingTemplate,
    required this.isPickingOrParsing,
    required this.isImporting,
    this.parsedFile,
    this.error,
    this.successMessage,
    this.templateSavePath,
    this.importResult,
  });

  factory SupplierExcelImportState.initial() {
    return const SupplierExcelImportState(
      isDownloadingTemplate: false,
      isPickingOrParsing: false,
      isImporting: false,
    );
  }

  String? get fileName => parsedFile?.fileName;
  bool get hasRows => parsedFile?.hasRows == true;
  bool get canImport => parsedFile?.canImport == true && !isImporting;

  int get totalRows => parsedFile?.totalRows ?? 0;
  int get validRowsCount => parsedFile?.validRows ?? 0;
  /// Total validation errors, not just number of invalid rows.
  /// This keeps the summary card consistent with the grouped issue list.
  int get errorRowsCount => parsedFile?.errorIssues ?? 0;

  /// Total validation warnings, not just number of rows with warnings.
  int get warningRowsCount => parsedFile?.warningIssues ?? 0;

  int sectionCount(SupplierExcelSection section) {
    return parsedFile?.rowsFor(section).length ?? 0;
  }

  SupplierExcelImportState copyWith({
    bool? isDownloadingTemplate,
    bool? isPickingOrParsing,
    bool? isImporting,
    SupplierExcelParsedFileEntity? parsedFile,
    String? error,
    String? successMessage,
    String? templateSavePath,
    SupplierExcelImportResultEntity? importResult,
    bool clearMessages = false,
    bool clearTemplatePath = false,
    bool clearParsedFile = false,
    bool clearImportResult = false,
  }) {
    return SupplierExcelImportState(
      isDownloadingTemplate:
          isDownloadingTemplate ?? this.isDownloadingTemplate,
      isPickingOrParsing: isPickingOrParsing ?? this.isPickingOrParsing,
      isImporting: isImporting ?? this.isImporting,
      parsedFile: clearParsedFile ? null : parsedFile ?? this.parsedFile,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
      templateSavePath:
          clearTemplatePath ? null : templateSavePath ?? this.templateSavePath,
      importResult: clearImportResult ? null : importResult ?? this.importResult,
    );
  }

  @override
  List<Object?> get props => [
        isDownloadingTemplate,
        isPickingOrParsing,
        isImporting,
        parsedFile,
        error,
        successMessage,
        templateSavePath,
        importResult,
      ];
}

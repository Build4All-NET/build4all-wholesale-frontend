import 'package:equatable/equatable.dart';

import 'supplier_excel_row_entity.dart';
import 'supplier_excel_section.dart';

class SupplierExcelParsedFileEntity extends Equatable {
  final String fileName;
  final Map<SupplierExcelSection, List<SupplierExcelRowEntity>> rowsBySection;

  const SupplierExcelParsedFileEntity({
    required this.fileName,
    required this.rowsBySection,
  });

  List<SupplierExcelRowEntity> rowsFor(SupplierExcelSection section) {
    return rowsBySection[section] ?? const [];
  }

  List<SupplierExcelRowEntity> get allRows {
    return SupplierExcelSection.values
        .expand((section) => rowsFor(section))
        .toList(growable: false);
  }

  int get totalRows => allRows.length;
  int get validRows => allRows.where((row) => row.isValid).length;

  /// Number of rows that contain at least one validation error.
  /// Keep this for row-level logic, but do not show it as the total error count.
  int get errorRows => allRows.where((row) => !row.isValid).length;

  /// Number of rows that contain at least one warning.
  int get warningRows => allRows.where((row) => row.hasWarnings).length;

  /// Total validation errors across all rows.
  /// Example: one branch row can have two errors: City + Region ID.
  int get errorIssues => allRows.fold<int>(
        0,
        (total, row) => total + row.errors.length,
      );

  /// Total warnings across all rows.
  int get warningIssues => allRows.fold<int>(
        0,
        (total, row) => total + row.warnings.length,
      );

  int errorIssuesFor(SupplierExcelSection section) {
    return rowsFor(section).fold<int>(
      0,
      (total, row) => total + row.errors.length,
    );
  }

  int warningIssuesFor(SupplierExcelSection section) {
    return rowsFor(section).fold<int>(
      0,
      (total, row) => total + row.warnings.length,
    );
  }

  bool get hasRows => totalRows > 0;
  bool get canImport => hasRows && errorIssues == 0;

  SupplierExcelParsedFileEntity copyWith({
    Map<SupplierExcelSection, List<SupplierExcelRowEntity>>? rowsBySection,
  }) {
    return SupplierExcelParsedFileEntity(
      fileName: fileName,
      rowsBySection: rowsBySection ?? this.rowsBySection,
    );
  }

  @override
  List<Object?> get props => [fileName, rowsBySection];
}

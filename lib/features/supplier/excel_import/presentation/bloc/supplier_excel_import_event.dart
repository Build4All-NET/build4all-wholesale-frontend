import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_section.dart';

abstract class SupplierExcelImportEvent extends Equatable {
  const SupplierExcelImportEvent();

  @override
  List<Object?> get props => [];
}

class SupplierExcelDownloadTemplateRequested extends SupplierExcelImportEvent {
  const SupplierExcelDownloadTemplateRequested();
}

class SupplierExcelPickFileRequested extends SupplierExcelImportEvent {
  const SupplierExcelPickFileRequested();
}

class SupplierExcelRowUpdated extends SupplierExcelImportEvent {
  final SupplierExcelSection section;
  final int rowNumber;
  final Map<String, String> values;

  const SupplierExcelRowUpdated({
    required this.section,
    required this.rowNumber,
    required this.values,
  });

  @override
  List<Object?> get props => [section, rowNumber, values];
}

class SupplierExcelImportRequested extends SupplierExcelImportEvent {
  const SupplierExcelImportRequested();
}

class SupplierExcelClearRequested extends SupplierExcelImportEvent {
  const SupplierExcelClearRequested();
}

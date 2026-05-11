import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_product_row_entity.dart';

abstract class SupplierExcelImportEvent extends Equatable {
  const SupplierExcelImportEvent();

  @override
  List<Object?> get props => [];
}

class SupplierExcelPickFileRequested extends SupplierExcelImportEvent {
  const SupplierExcelPickFileRequested();
}

class SupplierExcelImportRequested extends SupplierExcelImportEvent {
  const SupplierExcelImportRequested();
}

class SupplierExcelClearRequested extends SupplierExcelImportEvent {
  const SupplierExcelClearRequested();
}

class SupplierExcelRowUpdated extends SupplierExcelImportEvent {
  final SupplierExcelProductRowEntity row;

  const SupplierExcelRowUpdated({required this.row});

  @override
  List<Object?> get props => [row];
}

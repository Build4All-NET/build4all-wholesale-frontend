import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_product_row_entity.dart';

abstract class SupplierExcelImportEvent extends Equatable {
  SupplierExcelImportEvent();

  @override
  List<Object?> get props => [];
}

class SupplierExcelPickFileRequested extends SupplierExcelImportEvent {
  SupplierExcelPickFileRequested();
}

class SupplierExcelImportRequested extends SupplierExcelImportEvent {
  SupplierExcelImportRequested();
}

class SupplierExcelClearRequested extends SupplierExcelImportEvent {
  SupplierExcelClearRequested();
}

class SupplierExcelRowUpdated extends SupplierExcelImportEvent {
  final SupplierExcelProductRowEntity row;

  SupplierExcelRowUpdated({required this.row});

  @override
  List<Object?> get props => [row];
}

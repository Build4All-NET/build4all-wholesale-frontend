import 'package:equatable/equatable.dart';

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

import 'dart:typed_data';

import '../../data/services/supplier_foreign_import_api_service.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_foreign_preview.dart';
import '../entities/supplier_foreign_sheet_mapping.dart';
import '../repositories/supplier_foreign_import_repository.dart';

/// What each sheet of an uploaded file appears to hold.
class SuggestSupplierColumnMappingUseCase {
  final SupplierForeignImportRepository repository;

  const SuggestSupplierColumnMappingUseCase(this.repository);

  Future<List<SupplierForeignSheetMapping>> call({
    required String fileName,
    required Uint8List bytes,
    bool useAi = true,
  }) {
    return repository.suggestMapping(
      fileName: fileName,
      bytes: bytes,
      useAi: useAi,
    );
  }
}

/// What importing the confirmed sheet would create, without creating it.
class PreviewSupplierForeignFileUseCase {
  final SupplierForeignImportRepository repository;

  const PreviewSupplierForeignFileUseCase(this.repository);

  Future<SupplierForeignPreview> call({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) {
    return repository.preview(
      fileName: fileName,
      bytes: bytes,
      mapping: mapping,
      categoryName: categoryName,
      branchName: branchName,
      edits: edits,
    );
  }
}

/// Creates the catalogue from the reading the supplier confirmed.
class ImportSupplierForeignFileUseCase {
  final SupplierForeignImportRepository repository;

  const ImportSupplierForeignFileUseCase(this.repository);

  Future<SupplierExcelImportResultEntity> call({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    required int totalRows,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) {
    return repository.import(
      fileName: fileName,
      bytes: bytes,
      mapping: mapping,
      categoryName: categoryName,
      branchName: branchName,
      totalRows: totalRows,
      edits: edits,
    );
  }
}

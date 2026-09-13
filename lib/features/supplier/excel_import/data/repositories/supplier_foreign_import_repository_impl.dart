import 'dart:typed_data';

import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';
import '../../domain/repositories/supplier_foreign_import_repository.dart';
import '../services/supplier_foreign_import_api_service.dart';

class SupplierForeignImportRepositoryImpl
    implements SupplierForeignImportRepository {
  final SupplierForeignImportApiService apiService;

  const SupplierForeignImportRepositoryImpl({required this.apiService});

  @override
  Future<List<SupplierForeignSheetMapping>> suggestMapping({
    required String fileName,
    required Uint8List bytes,
    bool useAi = true,
  }) {
    return apiService.suggestMapping(
      fileName: fileName,
      bytes: bytes,
      useAi: useAi,
    );
  }

  @override
  Future<SupplierForeignPreview> preview({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) {
    return apiService.preview(
      fileName: fileName,
      bytes: bytes,
      mapping: mapping,
      categoryName: categoryName,
      branchName: branchName,
      edits: edits,
    );
  }

  @override
  Future<SupplierExcelImportResultEntity> import({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    required int totalRows,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) {
    return apiService.import(
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

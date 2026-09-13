import 'dart:typed_data';

import '../../data/services/supplier_foreign_import_api_service.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_foreign_preview.dart';
import '../entities/supplier_foreign_sheet_mapping.dart';

abstract class SupplierForeignImportRepository {
  Future<List<SupplierForeignSheetMapping>> suggestMapping({
    required String fileName,
    required Uint8List bytes,
    bool useAi,
  });

  Future<SupplierForeignPreview> preview({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    Map<int, SupplierForeignRowEdit> edits,
  });

  Future<SupplierExcelImportResultEntity> import({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    required int totalRows,
    Map<int, SupplierForeignRowEdit> edits,
  });
}

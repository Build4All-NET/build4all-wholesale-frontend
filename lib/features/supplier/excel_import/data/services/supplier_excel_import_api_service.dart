import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_excel_row_entity.dart';
import '../../domain/entities/supplier_excel_section.dart';

/// Sends the already-parsed, already-validated workbook rows to the backend
/// in one request. The server performs the find-or-create import for every
/// section inside a single DB transaction — replacing what used to be one
/// REST call per row from this client.
class SupplierExcelImportApiService {
  final ApiClient apiClient;

  SupplierExcelImportApiService(this.apiClient);

  Future<SupplierExcelImportResultEntity> importAll({
    required SupplierExcelParsedFileEntity parsedFile,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierExcelImport,
        data: _buildRequestBody(parsedFile),
      );

      return _resultFromJson(
        Map<String, dynamic>.from(response.data as Map),
        totalRows: parsedFile.totalRows,
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  Map<String, dynamic> _buildRequestBody(SupplierExcelParsedFileEntity parsedFile) {
    return {
      for (final section in SupplierExcelSection.values)
        _sectionKey(section): parsedFile
            .rowsFor(section)
            .where((row) => row.isValid)
            .map(_rowToJson)
            .toList(),
    };
  }

  Map<String, dynamic> _rowToJson(SupplierExcelRowEntity row) {
    return {
      'rowNumber': row.rowNumber,
      'values': row.values,
    };
  }

  String _sectionKey(SupplierExcelSection section) {
    switch (section) {
      case SupplierExcelSection.categories:
        return 'categories';
      case SupplierExcelSection.subCategories:
        return 'subCategories';
      case SupplierExcelSection.branches:
        return 'branches';
      case SupplierExcelSection.products:
        return 'products';
      case SupplierExcelSection.inventory:
        return 'inventory';
      case SupplierExcelSection.taxRules:
        return 'taxRules';
      case SupplierExcelSection.shippingMethods:
        return 'shippingMethods';
      case SupplierExcelSection.coupons:
        return 'coupons';
      case SupplierExcelSection.promotions:
        return 'promotions';
      case SupplierExcelSection.banners:
        return 'banners';
    }
  }

  SupplierExcelImportResultEntity _resultFromJson(
    Map<String, dynamic> json, {
    required int totalRows,
  }) {
    return SupplierExcelImportResultEntity(
      totalRows: totalRows,
      importedCount: (json['importedCount'] as num?)?.toInt() ?? 0,
      failedCount: (json['failedCount'] as num?)?.toInt() ?? 0,
      messages: (json['messages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      failedMessages:
          (json['failedMessages'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    return e.message ?? 'Something went wrong';
  }
}

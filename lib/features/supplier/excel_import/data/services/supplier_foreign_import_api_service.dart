import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_config.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';
import '../models/supplier_foreign_models.dart';

/// Importing a catalogue from a file this platform did not produce.
///
/// The file is uploaded at each of the three steps rather than parked on the
/// server between them: a half-finished import then leaves nothing of the
/// supplier's catalogue sitting in a temp directory, and the app already has
/// the bytes in hand.
class SupplierForeignImportApiService {
  final ApiClient apiClient;

  SupplierForeignImportApiService(this.apiClient);

  /// What each sheet of the file appears to hold.
  Future<List<SupplierForeignSheetMapping>> suggestMapping({
    required String fileName,
    required Uint8List bytes,
    bool useAi = true,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierForeignSuggestMapping,
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
          'useAi': useAi.toString(),
        }),
      );

      return SupplierForeignMapper.sheets(response.data);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// What importing the confirmed sheet would create, without creating it.
  Future<SupplierForeignPreview> preview({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierForeignPreview,
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
          'mapping': _mappingJson(mapping, categoryName, branchName),
          if (edits.isNotEmpty) 'edits': _editsJson(edits),
        }),
      );

      return SupplierForeignMapper.preview(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  /// Creates the catalogue from the reading the supplier confirmed.
  Future<SupplierExcelImportResultEntity> import({
    required String fileName,
    required Uint8List bytes,
    required SupplierForeignSheetMapping mapping,
    required String? categoryName,
    required String? branchName,
    required int totalRows,
    Map<int, SupplierForeignRowEdit> edits = const {},
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConfig.supplierForeignImport,
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
          'mapping': _mappingJson(mapping, categoryName, branchName),
          if (edits.isNotEmpty) 'edits': _editsJson(edits),
        }),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      return SupplierExcelImportResultEntity(
        importedCount: _int(data['importedCount']),
        failedCount: _int(data['failedCount']),
        totalRows: totalRows,
        messages: _strings(data['messages']),
        failedMessages: _strings(data['failedMessages']),
      );
    } on DioException catch (e) {
      throw AppException(_extractMessage(e));
    }
  }

  String _mappingJson(
    SupplierForeignSheetMapping mapping,
    String? categoryName,
    String? branchName,
  ) {
    return jsonEncode({
      'sheetName': mapping.sheetName,
      'columns': mapping.toWireColumns(),
      if (categoryName != null && categoryName.trim().isNotEmpty)
        'categoryName': categoryName.trim(),
      if (branchName != null && branchName.trim().isNotEmpty)
        'branchName': branchName.trim(),
    });
  }

  String _editsJson(Map<int, SupplierForeignRowEdit> edits) {
    return jsonEncode({
      for (final entry in edits.entries)
        '${entry.key}': {
          if (entry.value.price != null) 'price': entry.value.price,
          if (entry.value.stock != null) 'stock': entry.value.stock,
          if (entry.value.description != null)
            'description': entry.value.description,
        },
    });
  }

  static int _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static List<String> _strings(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
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

/// A change the supplier made to one row on the review screen.
///
/// Kept apart from the file: the file is what their other system said, and this
/// is what they decided while looking at it. A null field means "leave what the
/// file said", which keeps a zero they typed on purpose distinct from one they
/// never touched.
class SupplierForeignRowEdit {
  final double? price;
  final int? stock;
  final String? description;

  const SupplierForeignRowEdit({this.price, this.stock, this.description});

  bool get isEmpty => price == null && stock == null && description == null;

  SupplierForeignRowEdit copyWith({
    double? price,
    int? stock,
    String? description,
  }) {
    return SupplierForeignRowEdit(
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
    );
  }
}

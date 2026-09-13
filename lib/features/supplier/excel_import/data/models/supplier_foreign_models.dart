import '../../domain/entities/supplier_foreign_field.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';

/// Reading what the foreign-import endpoints send back.
class SupplierForeignMapper {
  const SupplierForeignMapper._();

  static SupplierForeignColumnGuess columnGuess(Map<String, dynamic> json) {
    return SupplierForeignColumnGuess(
      columnIndex: _int(json['columnIndex']) ?? 0,
      header: _str(json['header']),
      field: SupplierForeignField.fromWire(json['field']?.toString()),
      confidence: _double(json['confidence']) ?? 0,
      reason: SupplierForeignGuessReason.fromWire(json['reason']?.toString()),
      disputedWith: json['disputedWith'] == null
          ? null
          : SupplierForeignField.fromWire(json['disputedWith'].toString()),
    );
  }

  static SupplierForeignSheetMapping sheetMapping(Map<String, dynamic> json) {
    final raw = json['columns'];

    return SupplierForeignSheetMapping(
      sheetName: _str(json['sheetName']),
      dataRowCount: _int(json['dataRowCount']) ?? 0,
      columns: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => columnGuess(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      aiUsed: json['aiUsed'] == true,
    );
  }

  static List<SupplierForeignSheetMapping> sheets(dynamic data) {
    if (data is Map && data['sheets'] is List) {
      return (data['sheets'] as List)
          .whereType<Map>()
          .map((e) => sheetMapping(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  static SupplierForeignProductPreview productPreview(Map<String, dynamic> json) {
    return SupplierForeignProductPreview(
      row: _int(json['row']) ?? 0,
      name: _str(json['name']),
      description: _nullableStr(json['description']),
      price: _double(json['price']),
      stock: _int(json['stock']),
      moq: _int(json['moq']),
      categoryName: _nullableStr(json['categoryName']),
      imageUrl: _nullableStr(json['imageUrl']),
      valid: json['valid'] != false,
      issues: _strings(json['issues']),
      notes: _strings(json['notes']),
    );
  }

  static SupplierForeignPreview preview(Map<String, dynamic> json) {
    final raw = json['products'];

    return SupplierForeignPreview(
      products: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => productPreview(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      skippedRows: _int(json['skippedRows']) ?? 0,
      needingAttention: _int(json['needingAttention']) ?? 0,
    );
  }

  static List<String> _strings(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
  }

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  static String? _nullableStr(dynamic v) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? null : s;
  }

  static int? _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  static double? _double(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
}

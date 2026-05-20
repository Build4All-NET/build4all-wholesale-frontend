import 'package:equatable/equatable.dart';

import 'supplier_excel_section.dart';

class SupplierExcelRowEntity extends Equatable {
  final SupplierExcelSection section;
  final int rowNumber;
  final Map<String, String> values;
  final List<String> errors;
  final List<String> warnings;

  const SupplierExcelRowEntity({
    required this.section,
    required this.rowNumber,
    required this.values,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  String value(String key) {
    return values[_normalizeKey(key)]?.trim() ?? '';
  }

  String? optionalValue(String key) {
    final text = value(key);
    return text.isEmpty ? null : text;
  }

  SupplierExcelRowEntity copyWith({
    Map<String, String>? values,
    List<String>? errors,
    List<String>? warnings,
  }) {
    return SupplierExcelRowEntity(
      section: section,
      rowNumber: rowNumber,
      values: values ?? this.values,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
    );
  }

  static String normalizeHeader(String header) => _normalizeKey(header);

  static String _normalizeKey(String key) {
    return key
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  @override
  List<Object?> get props => [section, rowNumber, values, errors, warnings];
}

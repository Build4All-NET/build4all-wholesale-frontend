import 'package:equatable/equatable.dart';

import 'supplier_foreign_field.dart';

/// What one column of an uploaded file was taken to be, and how sure that is.
class SupplierForeignColumnGuess extends Equatable {
  final int columnIndex;
  final String header;
  final SupplierForeignField field;

  /// 0..1. Shown so a shaky guess reads as a question rather than a decision
  /// already taken.
  final double confidence;

  final SupplierForeignGuessReason reason;

  /// When the assistant and the values disagreed, what the values made of the
  /// column. Null otherwise.
  final SupplierForeignField? disputedWith;

  const SupplierForeignColumnGuess({
    required this.columnIndex,
    required this.header,
    required this.field,
    required this.confidence,
    required this.reason,
    required this.disputedWith,
  });

  bool get isIgnored => field == SupplierForeignField.ignore;

  /// Worth the supplier's eye before they confirm.
  bool get needsAttention =>
      reason == SupplierForeignGuessReason.disputed || confidence < 0.6;

  SupplierForeignColumnGuess copyWith({SupplierForeignField? field}) {
    return SupplierForeignColumnGuess(
      columnIndex: columnIndex,
      header: header,
      field: field ?? this.field,
      confidence: confidence,
      reason: reason,
      disputedWith: disputedWith,
    );
  }

  @override
  List<Object?> get props =>
      [columnIndex, header, field, confidence, reason, disputedWith];
}

/// What one sheet of an uploaded file was read as, ready to be confirmed.
class SupplierForeignSheetMapping extends Equatable {
  final String sheetName;
  final int dataRowCount;
  final List<SupplierForeignColumnGuess> columns;

  /// Whether a model was consulted. Shown plainly: a supplier reviewing a guess
  /// deserves to know who made it.
  final bool aiUsed;

  const SupplierForeignSheetMapping({
    required this.sheetName,
    required this.dataRowCount,
    required this.columns,
    required this.aiUsed,
  });

  /// True when the sheet has the one column without which no product can be made.
  bool get hasName =>
      columns.any((c) => c.field == SupplierForeignField.name);

  bool get hasStock =>
      columns.any((c) => c.field == SupplierForeignField.stock);

  bool get hasCategory =>
      columns.any((c) => c.field == SupplierForeignField.category);

  SupplierForeignSheetMapping withColumn(
    int columnIndex,
    SupplierForeignField field,
  ) {
    return SupplierForeignSheetMapping(
      sheetName: sheetName,
      dataRowCount: dataRowCount,
      columns: columns.map((c) {
        if (c.columnIndex == columnIndex) return c.copyWith(field: field);

        // A field belongs to one column. Handing it to this one takes it off
        // whichever column held it, rather than sending the server two claims
        // and letting it pick.
        if (field != SupplierForeignField.ignore && c.field == field) {
          return c.copyWith(field: SupplierForeignField.ignore);
        }
        return c;
      }).toList(),
      aiUsed: aiUsed,
    );
  }

  /// Column index to wire field name, for the columns actually being imported.
  Map<String, String> toWireColumns() {
    final map = <String, String>{};
    for (final column in columns) {
      if (column.isIgnored) continue;
      map['${column.columnIndex}'] = column.field.wireName;
    }
    return map;
  }

  @override
  List<Object?> get props => [sheetName, dataRowCount, columns, aiUsed];
}

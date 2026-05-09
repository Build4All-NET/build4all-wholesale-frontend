import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../models/supplier_excel_product_row_model.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_picked_excel_file_entity.dart';

class SupplierExcelReaderService {
  static const List<String> expectedHeaders = [
    'Product Name',
    'Description',
    'Category',
    'SubCategory',
    'Price',
    'MOQ',
    'Status',
  ];

  Future<SupplierPickedExcelFileEntity?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw Exception('Could not read the selected Excel file.');
    }

    return SupplierPickedExcelFileEntity(
      fileName: file.name,
      bytes: Uint8List.fromList(bytes),
    );
  }

  Future<SupplierExcelParsedFileEntity> parseExcelFile({
    required SupplierPickedExcelFileEntity file,
  }) async {
    final excel = Excel.decodeBytes(file.bytes);

    if (excel.tables.isEmpty) {
      throw Exception('The selected Excel file is empty.');
    }

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];

    if (sheet == null || sheet.rows.isEmpty) {
      throw Exception('The selected Excel file does not contain rows.');
    }

    final headerCells = sheet.rows.first.map(_cellToText).toList();
    _validateHeaders(headerCells);

    final rows = <SupplierExcelProductRowModel>[];

    for (var index = 1; index < sheet.rows.length; index++) {
      final cells = sheet.rows[index].map(_cellToText).toList();

      final isEmptyRow = cells.every((cell) => cell.trim().isEmpty);
      if (isEmptyRow) continue;

      rows.add(
        SupplierExcelProductRowModel.fromCells(
          rowNumber: index + 1,
          cells: cells,
        ),
      );
    }

    if (rows.isEmpty) {
      throw Exception('No product rows found after the header row.');
    }

    return SupplierExcelParsedFileEntity(
      fileName: file.fileName,
      rows: rows,
    );
  }

  void _validateHeaders(List<String> headers) {
    if (headers.length < expectedHeaders.length) {
      throw Exception(
        'Invalid Excel format. Expected columns: ${expectedHeaders.join(', ')}.',
      );
    }

    for (var index = 0; index < expectedHeaders.length; index++) {
      final actual = _normalizeHeader(headers[index]);
      final expected = _normalizeHeader(expectedHeaders[index]);

      if (actual != expected) {
        throw Exception(
          'Invalid column ${index + 1}. Expected "${expectedHeaders[index]}" but found "${headers[index]}".',
        );
      }
    }
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _cellToText(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';

    if (value is String || value is num || value is bool) {
      return value.toString().trim();
    }

    try {
      final dynamic dynamicValue = value;
      final innerValue = dynamicValue.value;
      if (innerValue != null) return innerValue.toString().trim();
    } catch (_) {
      // Keeps compatibility with different excel package cell value classes.
    }

    try {
      final dynamic dynamicValue = value;
      final textValue = dynamicValue.text;
      if (textValue != null) return textValue.toString().trim();
    } catch (_) {
      // Keeps compatibility with different excel package cell value classes.
    }

    final raw = value.toString().trim();
    final match = RegExp(r'^[A-Za-z]+CellValue\((.*)\)$').firstMatch(raw);
    return match == null ? raw : match.group(1)!.trim();
  }
}

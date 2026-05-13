import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';

import '../models/supplier_excel_product_row_model.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_picked_excel_file_entity.dart';

class SupplierExcelReaderService {
  static List<String> expectedHeaders = [
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
      allowedExtensions: ['xlsx'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw Exception('Could not read the selected Excel file.');
    }

    if (!file.name.toLowerCase().endsWith('.xlsx')) {
      throw Exception('Please select an .xlsx Excel file.');
    }

    return SupplierPickedExcelFileEntity(
      fileName: file.name,
      bytes: Uint8List.fromList(bytes),
    );
  }

  Future<SupplierExcelParsedFileEntity> parseExcelFile({
    required SupplierPickedExcelFileEntity file,
  }) async {
    try {
      final archive = ZipDecoder().decodeBytes(file.bytes);

      final sharedStrings = _readSharedStrings(archive);
      final sheetPath = _resolveFirstWorksheetPath(archive);
      final sheetXml = _readArchiveText(archive, sheetPath);

      if (sheetXml == null || sheetXml.trim().isEmpty) {
        throw Exception(
          'The selected Excel file does not contain a readable worksheet.',
        );
      }

      final allRows = _readWorksheetRows(
        sheetXml: sheetXml,
        sharedStrings: sharedStrings,
      );

      if (allRows.isEmpty) {
        throw Exception('The selected Excel file does not contain rows.');
      }

      final headerCells = allRows.first.cells;
      _validateHeaders(headerCells);

      final rows = <SupplierExcelProductRowModel>[];

      for (var index = 1; index < allRows.length; index++) {
        final row = allRows[index];

        final isEmptyRow = row.cells.every((cell) => cell.trim().isEmpty);
        if (isEmptyRow) continue;

        rows.add(
          SupplierExcelProductRowModel.fromCells(
            rowNumber: row.rowNumber,
            cells: row.cells,
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
    } on FormatException {
      throw Exception('Invalid Excel file. Please upload a valid .xlsx file.');
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '').trim();

      if (message.contains('Damaged Excel file: styles')) {
        throw Exception(
          'This Excel file contains unsupported styling. Please copy the rows into a clean .xlsx file and try again.',
        );
      }

      throw Exception(
        message.isEmpty ? 'Could not read the selected Excel file.' : message,
      );
    }
  }

  List<_ParsedWorksheetRow> _readWorksheetRows({
    required String sheetXml,
    required List<String> sharedStrings,
  }) {
    final rows = <_ParsedWorksheetRow>[];

    final rowRegex = RegExp(
      r'<(?:[A-Za-z0-9_]+:)?row\b([^>]*)>(.*?)</(?:[A-Za-z0-9_]+:)?row>',
      dotAll: true,
      caseSensitive: false,
    );

    final cellRegex = RegExp(
      r'<(?:[A-Za-z0-9_]+:)?c\b([^>]*)>(.*?)</(?:[A-Za-z0-9_]+:)?c>',
      dotAll: true,
      caseSensitive: false,
    );

    for (final rowMatch in rowRegex.allMatches(sheetXml)) {
      final rowAttributes = rowMatch.group(1) ?? '';
      final rowBody = rowMatch.group(2) ?? '';
      final rowNumber = int.tryParse(_readAttribute(rowAttributes, 'r') ?? '') ??
          (rows.length + 1);

      final cells = <String>[];

      for (final cellMatch in cellRegex.allMatches(rowBody)) {
        final cellAttributes = cellMatch.group(1) ?? '';
        final cellBody = cellMatch.group(2) ?? '';

        final cellReference = _readAttribute(cellAttributes, 'r');
        final columnIndex =
            _columnIndexFromCellReference(cellReference) ?? cells.length;

        while (cells.length <= columnIndex) {
          cells.add('');
        }

        cells[columnIndex] = _readCellValue(
          attributes: cellAttributes,
          body: cellBody,
          sharedStrings: sharedStrings,
        );
      }

      if (cells.isNotEmpty) {
        rows.add(_ParsedWorksheetRow(rowNumber: rowNumber, cells: cells));
      }
    }

    return rows;
  }

  String _readCellValue({
    required String attributes,
    required String body,
    required List<String> sharedStrings,
  }) {
    final type = _readAttribute(attributes, 't');

    if (type == 's') {
      final rawIndex = _readTagText(body, 'v');
      final index = int.tryParse(rawIndex ?? '');
      if (index == null || index < 0 || index >= sharedStrings.length) {
        return '';
      }
      return sharedStrings[index].trim();
    }

    if (type == 'inlineStr') {
      return _readAllTagTexts(body, 't').trim();
    }

    final value = _readTagText(body, 'v');
    if (value != null) return _decodeXml(value).trim();

    return _readAllTagTexts(body, 't').trim();
  }

  List<String> _readSharedStrings(Archive archive) {
    final xml = _readArchiveText(archive, 'xl/sharedStrings.xml');
    if (xml == null || xml.trim().isEmpty) return [];

    final strings = <String>[];
    final sharedStringRegex = RegExp(
      r'<(?:[A-Za-z0-9_]+:)?si\b[^>]*>(.*?)</(?:[A-Za-z0-9_]+:)?si>',
      dotAll: true,
      caseSensitive: false,
    );

    for (final match in sharedStringRegex.allMatches(xml)) {
      final body = match.group(1) ?? '';
      strings.add(_readAllTagTexts(body, 't').trim());
    }

    return strings;
  }

  String _resolveFirstWorksheetPath(Archive archive) {
    final workbookXml = _readArchiveText(archive, 'xl/workbook.xml');
    final relsXml = _readArchiveText(archive, 'xl/_rels/workbook.xml.rels');

    if (workbookXml != null && relsXml != null) {
      final sheetMatch = RegExp(
        r'<(?:[A-Za-z0-9_]+:)?sheet\b[^>]*r:id="([^"]+)"',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(workbookXml);

      final relationshipId = sheetMatch?.group(1);

      if (relationshipId != null) {
        final relationshipRegex = RegExp(
          r'<Relationship\b([^>]*)/?>',
          dotAll: true,
          caseSensitive: false,
        );

        for (final match in relationshipRegex.allMatches(relsXml)) {
          final attributes = match.group(1) ?? '';
          final id = _readAttribute(attributes, 'Id');
          final target = _readAttribute(attributes, 'Target');

          if (id == relationshipId && target != null && target.trim().isNotEmpty) {
            var path = target.trim();

            if (path.startsWith('/')) {
              path = path.substring(1);
            } else if (!path.startsWith('xl/')) {
              path = 'xl/$path';
            }

            return path;
          }
        }
      }
    }

    return 'xl/worksheets/sheet1.xml';
  }

  String? _readArchiveText(Archive archive, String path) {
    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (file.name != path) continue;

      final content = file.content;
      if (content is List<int>) {
        return utf8.decode(content);
      }

      return utf8.decode(content as List<int>);
    }

    return null;
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

  String? _readAttribute(String attributes, String name) {
    final doubleQuoteMatch = RegExp('$name="([^"]*)"').firstMatch(attributes);
    if (doubleQuoteMatch != null) return doubleQuoteMatch.group(1);

    final singleQuoteMatch = RegExp("$name='([^']*)'").firstMatch(attributes);
    return singleQuoteMatch?.group(1);
  }

  String? _readTagText(String xml, String tagName) {
    final match = RegExp(
      '<(?:[A-Za-z0-9_]+:)?$tagName\\b[^>]*>(.*?)</(?:[A-Za-z0-9_]+:)?$tagName>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(xml);

    if (match == null) return null;
    return _decodeXml(match.group(1) ?? '');
  }

  String _readAllTagTexts(String xml, String tagName) {
    final regex = RegExp(
      '<(?:[A-Za-z0-9_]+:)?$tagName\\b[^>]*>(.*?)</(?:[A-Za-z0-9_]+:)?$tagName>',
      dotAll: true,
      caseSensitive: false,
    );

    return regex
        .allMatches(xml)
        .map((match) => _decodeXml(match.group(1) ?? ''))
        .join();
  }

  int? _columnIndexFromCellReference(String? reference) {
    if (reference == null || reference.trim().isEmpty) return null;

    final letters = RegExp(r'^[A-Za-z]+').stringMatch(reference);
    if (letters == null || letters.isEmpty) return null;

    var index = 0;
    for (final codeUnit in letters.toUpperCase().codeUnits) {
      index = index * 26 + (codeUnit - 64);
    }

    return index - 1;
  }

  String _decodeXml(String value) {
    var decoded = value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');

    decoded = decoded.replaceAllMapped(
      RegExp(r'&#x([0-9A-Fa-f]+);'),
      (match) {
        final codePoint = int.tryParse(match.group(1)!, radix: 16);
        return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
      },
    );

    decoded = decoded.replaceAllMapped(
      RegExp(r'&#([0-9]+);'),
      (match) {
        final codePoint = int.tryParse(match.group(1)!);
        return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
      },
    );

    return decoded;
  }
}

class _ParsedWorksheetRow {
  final int rowNumber;
  final List<String> cells;

  _ParsedWorksheetRow({
    required this.rowNumber,
    required this.cells,
  });
}

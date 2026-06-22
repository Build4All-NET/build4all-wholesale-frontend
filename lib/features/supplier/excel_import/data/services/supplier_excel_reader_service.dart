import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_excel_row_entity.dart';
import '../../domain/entities/supplier_excel_section.dart';
import '../../domain/entities/supplier_picked_excel_file_entity.dart';

class SupplierExcelReaderService {
  static const Map<SupplierExcelSection, List<String>> expectedHeaders = {
    SupplierExcelSection.categories: ['Name', 'Status'],
    SupplierExcelSection.subCategories: ['Category', 'SubCategory', 'Status'],
    SupplierExcelSection.branches: [
      'Branch Name',
      'Country Code',
      'Region ID',
      'City',
      'Address',
      'Phone',
      'Status',
    ],
    SupplierExcelSection.products: [
      'Product Name',
      'Description',
      'Category',
      'SubCategory',
      'Price',
      'MOQ',
      'Status',
      'Image Url',
    ],
    SupplierExcelSection.inventory: [
      'Branch',
      'Product Name',
      'Stock Quantity',
    ],
    SupplierExcelSection.taxRules: [
      'Rule Name',
      'Rate',
      'Country ID',
      'Country Name',
      'Region ID',
      'Region Name',
      'Applies To Shipping',
      'Active',
      'Notes',
    ],
    SupplierExcelSection.shippingMethods: [
      'Name',
      'Type',
      'Country ID',
      'Country Name',
      'Region ID',
      'Region Name',
      'Cost',
      'Estimated Delivery Time',
      'Minimum Order Amount',
      'Free Shipping Threshold',
      'Branch Scope',
      'Branch Names',
      'Active',
      'Notes',
    ],
    SupplierExcelSection.coupons: [
      'Code',
      'Description',
      'Discount Type',
      'Discount Value',
      'Max Uses',
      'Min Order Amount',
      'Max Discount Amount',
      'Starts At',
      'Expires At',
      'Branch Scope',
      'Branch Names',
      'Active',
    ],
    SupplierExcelSection.promotions: [
      'Title',
      'Description',
      'Discount Type',
      'Discount Value',
      'Target Type',
      'Target Name',
      'Min Order Amount',
      'Max Discount Amount',
      'Start Date',
      'End Date',
      'Active',
    ],
    SupplierExcelSection.banners: [
      'Title',
      'Subtitle',
      'Image URL',
      'Target Type',
      'Target Value',
      'Sort Order',
      'Start Date',
      'End Date',
      'Active',
    ],
  };

  static List<String> headersFor(SupplierExcelSection section) {
    return expectedHeaders[section] ?? const [];
  }

  static String normalizeHeaderForUi(String header) {
    return SupplierExcelRowEntity.normalizeHeader(header);
  }

  Future<SupplierPickedExcelFileEntity?> pickExcelFile() async {
    final result = await FilePicker.pickFiles(
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
      final sheets = _resolveWorksheets(archive);

      if (sheets.isEmpty) {
        throw Exception('The selected Excel file does not contain worksheets.');
      }

      final rowsBySection =
          <SupplierExcelSection, List<SupplierExcelRowEntity>>{};

      for (final sheet in sheets) {
        final section = SupplierExcelSectionX.fromSheetName(sheet.name);
        if (section == null) continue;

        final sheetXml = _readArchiveText(archive, sheet.path);
        if (sheetXml == null || sheetXml.trim().isEmpty) continue;

        final allRows = _readWorksheetRows(
          sheetXml: sheetXml,
          sharedStrings: sharedStrings,
        );

        if (allRows.isEmpty) continue;

        final headerCells = allRows.first.cells;
        final headerMap = _buildHeaderMap(headerCells);
        final expected = expectedHeaders[section] ?? const <String>[];

        final missingRequiredHeaders = _missingRequiredHeaders(
          section: section,
          normalizedHeaders: headerMap.keys.toSet(),
        );

        if (missingRequiredHeaders.isNotEmpty) {
          throw Exception(
            '${sheet.name} sheet is missing required columns: ${missingRequiredHeaders.join(', ')}.',
          );
        }

        final parsedRows = <SupplierExcelRowEntity>[];

        for (var index = 1; index < allRows.length; index++) {
          final row = allRows[index];
          final isEmptyRow = row.cells.every((cell) => cell.trim().isEmpty);
          if (isEmptyRow) continue;

          final values = <String, String>{};

          for (final header in expected) {
            final key = SupplierExcelRowEntity.normalizeHeader(header);
            final columnIndex = headerMap[key];
            values[key] = columnIndex == null || columnIndex >= row.cells.length
                ? ''
                : row.cells[columnIndex].trim();
          }

          // Extra columns are kept for display/debugging but not required.
          for (final entry in headerMap.entries) {
            values.putIfAbsent(
              entry.key,
              () => entry.value >= row.cells.length
                  ? ''
                  : row.cells[entry.value].trim(),
            );
          }

          parsedRows.add(
            SupplierExcelRowEntity(
              section: section,
              rowNumber: row.rowNumber,
              values: values,
            ),
          );
        }

        if (parsedRows.isNotEmpty) {
          rowsBySection[section] = parsedRows;
        }
      }

      // Backward compatibility with the old one-sheet product template.
      if (rowsBySection.isEmpty) {
        final firstSheet = sheets.first;
        final sheetXml = _readArchiveText(archive, firstSheet.path);

        if (sheetXml != null && sheetXml.trim().isNotEmpty) {
          final allRows = _readWorksheetRows(
            sheetXml: sheetXml,
            sharedStrings: sharedStrings,
          );

          if (allRows.isNotEmpty) {
            final headerMap = _buildHeaderMap(allRows.first.cells);
            final requiredProductHeaders = _missingRequiredHeaders(
              section: SupplierExcelSection.products,
              normalizedHeaders: headerMap.keys.toSet(),
            );

            if (requiredProductHeaders.isEmpty) {
              final parsedRows = <SupplierExcelRowEntity>[];

              for (var index = 1; index < allRows.length; index++) {
                final row = allRows[index];
                if (row.cells.every((cell) => cell.trim().isEmpty)) continue;

                final values = <String, String>{};
                for (final header in headersFor(
                  SupplierExcelSection.products,
                )) {
                  final key = SupplierExcelRowEntity.normalizeHeader(header);
                  final columnIndex = headerMap[key];
                  values[key] =
                      columnIndex == null || columnIndex >= row.cells.length
                      ? ''
                      : row.cells[columnIndex].trim();
                }

                parsedRows.add(
                  SupplierExcelRowEntity(
                    section: SupplierExcelSection.products,
                    rowNumber: row.rowNumber,
                    values: values,
                  ),
                );
              }

              if (parsedRows.isNotEmpty) {
                rowsBySection[SupplierExcelSection.products] = parsedRows;
              }
            }
          }
        }
      }

      if (rowsBySection.isEmpty) {
        throw Exception(
          'No supported supplier sheets were found. Use the supplier template sheets: Categories, SubCategories, Branches, Products, BranchInventory, TaxRules, ShippingMethods, Coupons, Promotions, and Banners.',
        );
      }

      return SupplierExcelParsedFileEntity(
        fileName: file.fileName,
        rowsBySection: rowsBySection,
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
      final rowNumber =
          int.tryParse(_readAttribute(rowAttributes, 'r') ?? '') ??
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

  List<_WorksheetInfo> _resolveWorksheets(Archive archive) {
    final workbookXml = _readArchiveText(archive, 'xl/workbook.xml');
    final relsXml = _readArchiveText(archive, 'xl/_rels/workbook.xml.rels');

    if (workbookXml == null || relsXml == null) return const [];

    final relationshipTargets = <String, String>{};
    final relationshipRegex = RegExp(
      r'<(?:[A-Za-z0-9_]+:)?Relationship\b([^>]*)/?>',
      caseSensitive: false,
    );

    for (final match in relationshipRegex.allMatches(relsXml)) {
      final attributes = match.group(1) ?? '';
      final id = _readAttribute(attributes, 'Id');
      final target = _readAttribute(attributes, 'Target');
      if (id == null || target == null) continue;

      final normalizedTarget = target.startsWith('/')
          ? target.substring(1)
          : target.startsWith('xl/')
          ? target
          : 'xl/$target';

      relationshipTargets[id] = normalizedTarget;
    }

    final sheets = <_WorksheetInfo>[];
    final sheetRegex = RegExp(
      r'<(?:[A-Za-z0-9_]+:)?sheet\b([^>]*)/?>',
      caseSensitive: false,
    );

    for (final match in sheetRegex.allMatches(workbookXml)) {
      final attributes = match.group(1) ?? '';
      final name = _readAttribute(attributes, 'name');
      final relationshipId = _readAttribute(attributes, 'r:id');
      if (name == null || relationshipId == null) continue;

      final path = relationshipTargets[relationshipId];
      if (path == null) continue;

      sheets.add(_WorksheetInfo(name: name, path: path));
    }

    return sheets;
  }

  Map<String, int> _buildHeaderMap(List<String> headerCells) {
    final map = <String, int>{};
    for (var i = 0; i < headerCells.length; i++) {
      final normalized = SupplierExcelRowEntity.normalizeHeader(headerCells[i]);
      if (normalized.isEmpty) continue;
      map[normalized] = i;
    }
    return map;
  }

  List<String> _missingRequiredHeaders({
    required SupplierExcelSection section,
    required Set<String> normalizedHeaders,
  }) {
    final requiredHeaders = <String>[];

    switch (section) {
      case SupplierExcelSection.categories:
        requiredHeaders.add('Name');
        break;
      case SupplierExcelSection.subCategories:
        requiredHeaders.addAll(['Category', 'SubCategory']);
        break;
      case SupplierExcelSection.branches:
        requiredHeaders.addAll([
          'Branch Name',
          'Country Code',
          'City',
          'Address',
          'Phone',
        ]);
        break;
      case SupplierExcelSection.products:
        requiredHeaders.addAll([
          'Product Name',
          'Description',
          'Category',
          'Price',
          'MOQ',
        ]);
        break;
      case SupplierExcelSection.inventory:
        requiredHeaders.addAll(['Branch', 'Product Name', 'Stock Quantity']);
        break;
      case SupplierExcelSection.taxRules:
        requiredHeaders.addAll([
          'Rule Name',
          'Rate',
          'Country ID',
          'Country Name',
        ]);
        break;
      case SupplierExcelSection.shippingMethods:
        requiredHeaders.addAll([
          'Name',
          'Type',
          'Cost',
          'Estimated Delivery Time',
        ]);
        break;
      case SupplierExcelSection.coupons:
        requiredHeaders.addAll(['Code', 'Discount Type', 'Discount Value']);
        break;
      case SupplierExcelSection.promotions:
        requiredHeaders.addAll([
          'Title',
          'Discount Type',
          'Discount Value',
          'Target Type',
          'Target Name',
          'Start Date',
          'End Date',
        ]);
        break;
      case SupplierExcelSection.banners:
        requiredHeaders.addAll(['Title', 'Image URL', 'Target Type']);
        break;
    }

    return requiredHeaders
        .where(
          (header) => !normalizedHeaders.contains(
            SupplierExcelRowEntity.normalizeHeader(header),
          ),
        )
        .toList(growable: false);
  }

  String? _readArchiveText(Archive archive, String path) {
    final file = archive.files
        .where((item) => item.name == path)
        .cast<ArchiveFile?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (file == null || !file.isFile) return null;
    return utf8.decode(file.content as List<int>);
  }

  String? _readAttribute(String attributes, String name) {
    final escapedName = RegExp.escape(name);
    final regex = RegExp('$escapedName="([^"]*)"', caseSensitive: false);
    return _decodeXml(regex.firstMatch(attributes)?.group(1) ?? '');
  }

  String? _readTagText(String body, String tagName) {
    final escaped = RegExp.escape(tagName);
    final regex = RegExp(
      '<(?:[A-Za-z0-9_]+:)?$escaped\\b[^>]*>(.*?)</(?:[A-Za-z0-9_]+:)?$escaped>',
      dotAll: true,
      caseSensitive: false,
    );
    return regex.firstMatch(body)?.group(1);
  }

  String _readAllTagTexts(String body, String tagName) {
    final escaped = RegExp.escape(tagName);
    final regex = RegExp(
      '<(?:[A-Za-z0-9_]+:)?$escaped\\b[^>]*>(.*?)</(?:[A-Za-z0-9_]+:)?$escaped>',
      dotAll: true,
      caseSensitive: false,
    );
    return regex
        .allMatches(body)
        .map((match) => _decodeXml(match.group(1) ?? ''))
        .join('')
        .trim();
  }

  String _decodeXml(String value) {
    return value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  int? _columnIndexFromCellReference(String? reference) {
    if (reference == null || reference.isEmpty) return null;

    final letters = RegExp(
      r'^[A-Z]+',
      caseSensitive: false,
    ).firstMatch(reference)?.group(0);
    if (letters == null) return null;

    var index = 0;
    for (final codeUnit in letters.toUpperCase().codeUnits) {
      index = index * 26 + (codeUnit - 64);
    }

    return index - 1;
  }
}

class _ParsedWorksheetRow {
  final int rowNumber;
  final List<String> cells;

  const _ParsedWorksheetRow({required this.rowNumber, required this.cells});
}

class _WorksheetInfo {
  final String name;
  final String path;

  const _WorksheetInfo({required this.name, required this.path});
}

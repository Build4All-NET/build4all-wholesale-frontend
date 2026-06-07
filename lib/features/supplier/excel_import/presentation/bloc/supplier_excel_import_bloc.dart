import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../branches/domain/usecases/get_branches_usecase.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/usecases/clear_supplier_excel_import_usecase.dart';
import '../../domain/usecases/import_supplier_excel_products_usecase.dart';
import '../../domain/usecases/parse_supplier_excel_file_usecase.dart';
import '../../domain/usecases/pick_supplier_excel_file_usecase.dart';
import '../../domain/usecases/validate_supplier_excel_rows_usecase.dart';
import 'supplier_excel_import_event.dart';
import 'supplier_excel_import_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierExcelImportBloc
    extends Bloc<SupplierExcelImportEvent, SupplierExcelImportState> {
  static const String _templateAssetPath =
      'assets/templates/supplier_import_template.xlsx';

  final PickSupplierExcelFileUseCase pickSupplierExcelFileUseCase;
  final ParseSupplierExcelFileUseCase parseSupplierExcelFileUseCase;
  final ValidateSupplierExcelRowsUseCase validateSupplierExcelRowsUseCase;
  final ImportSupplierExcelProductsUseCase importSupplierExcelProductsUseCase;
  final ClearSupplierExcelImportUseCase clearSupplierExcelImportUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubCategoriesByCategoryUseCase getSubCategoriesByCategoryUseCase;
  final GetProductsUseCase getProductsUseCase;
  final GetBranchesUseCase getBranchesUseCase;

  SupplierExcelImportBloc({
    required this.pickSupplierExcelFileUseCase,
    required this.parseSupplierExcelFileUseCase,
    required this.validateSupplierExcelRowsUseCase,
    required this.importSupplierExcelProductsUseCase,
    required this.clearSupplierExcelImportUseCase,
    required this.getCategoriesUseCase,
    required this.getSubCategoriesByCategoryUseCase,
    required this.getProductsUseCase,
    required this.getBranchesUseCase,
  }) : super(SupplierExcelImportState.initial()) {
    on<SupplierExcelDownloadTemplateRequested>(_onDownloadTemplateRequested);
    on<SupplierExcelPickFileRequested>(_onPickFileRequested);
    on<SupplierExcelRowUpdated>(_onRowUpdated);
    on<SupplierExcelImportRequested>(_onImportRequested);
    on<SupplierExcelClearRequested>(_onClearRequested);
  }

  Future<void> _onDownloadTemplateRequested(
    SupplierExcelDownloadTemplateRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (state.isDownloadingTemplate) return;

    emit(
      state.copyWith(
        isDownloadingTemplate: true,
        clearMessages: true,
        clearTemplatePath: true,
      ),
    );

    try {
      final data = await rootBundle.load(_templateAssetPath);
      final bytes = data.buffer.asUint8List();

      if (!_looksLikeXlsx(bytes)) {
        throw Exception('The supplier template asset is not a valid .xlsx file.');
      }

      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save supplier Excel import template',
        fileName: 'supplier_import_template.xlsx',
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        bytes: bytes,
      );

      final savedPath = selectedPath == null
          ? null
          : await _ensureTemplateSavedAsXlsx(
              selectedPath: selectedPath,
              bytes: bytes,
            );

      emit(
        state.copyWith(
          isDownloadingTemplate: false,
          successMessage: savedPath == null
              ? null
              : 'supplierExcelTemplateDownloaded',
          templateSavePath: savedPath,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isDownloadingTemplate: false,
          error: _message(error),
        ),
      );
    }
  }


  bool _looksLikeXlsx(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // .xlsx files are ZIP archives and must start with PK.
    return bytes[0] == 0x50 && bytes[1] == 0x4B;
  }

  Future<String> _ensureTemplateSavedAsXlsx({
    required String selectedPath,
    required Uint8List bytes,
  }) async {
    // Some Android/desktop file pickers may return a path without the .xlsx
    // extension even when the suggested file name has it. In that case, Excel
    // and Google Sheets may not recognize the file. We enforce the extension
    // and also write the bytes ourselves when the returned path is a normal
    // filesystem path.
    if (selectedPath.startsWith('content://')) {
      return selectedPath;
    }

    final normalizedPath = selectedPath.trim();
    final finalPath = normalizedPath.toLowerCase().endsWith('.xlsx')
        ? normalizedPath
        : '$normalizedPath.xlsx';

    final file = File(finalPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    if (finalPath != normalizedPath) {
      final wrongExtensionFile = File(normalizedPath);
      if (await wrongExtensionFile.exists()) {
        try {
          await wrongExtensionFile.delete();
        } catch (_) {
          // Best effort only. The correctly named .xlsx file was already saved.
        }
      }
    }

    return finalPath;
  }

  Future<void> _onPickFileRequested(
    SupplierExcelPickFileRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    emit(
      state.copyWith(
        isPickingOrParsing: true,
        clearMessages: true,
        clearImportResult: true,
      ),
    );

    try {
      final pickedFile = await pickSupplierExcelFileUseCase();

      if (pickedFile == null) {
        emit(
          state.copyWith(
            isPickingOrParsing: false,
            clearMessages: true,
            clearImportResult: true,
          ),
        );
        return;
      }

      final parsedFile = await parseSupplierExcelFileUseCase(file: pickedFile);
      final validatedFile = await _validateFile(parsedFile);

      emit(
        state.copyWith(
          isPickingOrParsing: false,
          parsedFile: validatedFile,
          clearMessages: true,
          clearImportResult: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isPickingOrParsing: false,
          error: _message(error),
          clearImportResult: true,
        ),
      );
    }
  }


  Future<void> _onRowUpdated(
    SupplierExcelRowUpdated event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    final currentFile = state.parsedFile;
    if (currentFile == null) return;

    final rowsBySection = {...currentFile.rowsBySection};
    final rows = List.of(currentFile.rowsFor(event.section));
    final index = rows.indexWhere((row) => row.rowNumber == event.rowNumber);
    if (index < 0) return;

    rows[index] = rows[index].copyWith(values: event.values);
    rowsBySection[event.section] = rows;

    final editedFile = SupplierExcelParsedFileEntity(
      fileName: currentFile.fileName,
      rowsBySection: Map.from(rowsBySection),
    );

    emit(
      state.copyWith(
        parsedFile: editedFile,
        clearMessages: true,
        clearImportResult: true,
      ),
    );

    try {
      final validatedFile = await _validateFile(editedFile);
      emit(
        state.copyWith(
          parsedFile: validatedFile,
          clearMessages: true,
          clearImportResult: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          error: _message(error),
          clearImportResult: true,
        ),
      );
    }
  }

  Future<SupplierExcelParsedFileEntity> _validateFile(
    SupplierExcelParsedFileEntity parsedFile,
  ) async {
    final categories = await getCategoriesUseCase();
    final existingProducts = await getProductsUseCase();
    final existingBranches = await getBranchesUseCase();
    final subCategoriesByCategoryId = <String, List<SupplierSubCategoryEntity>>{};

    for (final category in categories) {
      subCategoriesByCategoryId[category.id] =
          await getSubCategoriesByCategoryUseCase(categoryId: category.id);
    }

    return validateSupplierExcelRowsUseCase(
      parsedFile: parsedFile,
      categories: categories,
      subCategoriesByCategoryId: subCategoriesByCategoryId,
      existingProducts: existingProducts,
      existingBranches: existingBranches,
    );
  }

  Future<void> _onImportRequested(
    SupplierExcelImportRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (!state.canImport || state.parsedFile == null) return;

    emit(
      state.copyWith(
        isImporting: true,
        clearMessages: true,
      ),
    );

    try {
      final result = await importSupplierExcelProductsUseCase(
        parsedFile: state.parsedFile!,
      );

      emit(
        state.copyWith(
          isImporting: false,
          importResult: result,
          successMessage: result.hasFailures
              ? 'supplierExcelImportPartial'
              : 'supplierExcelImportSuccess',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isImporting: false,
          error: _message(error),
        ),
      );
    }
  }

  void _onClearRequested(
    SupplierExcelClearRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    clearSupplierExcelImportUseCase();

    emit(SupplierExcelImportState.initial());
  }

  String _message(Object error) {
    return AppErrorMapper.toMessage(error);
  }
}

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../data/services/supplier_foreign_import_api_service.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_foreign_field.dart';
import '../../data/services/supplier_product_ai_api_service.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';
import '../../domain/usecases/pick_supplier_excel_file_usecase.dart';
import '../../domain/usecases/supplier_foreign_import_usecases.dart';

/// Where the supplier is in the three steps.
enum SupplierForeignStep { pickFile, confirmColumns, review, done }

class SupplierForeignImportState {
  final SupplierForeignStep step;

  final String? fileName;
  final Uint8List? bytes;

  /// Every sheet of the file that could be a product list.
  final List<SupplierForeignSheetMapping> sheets;
  final int selectedSheet;

  final String categoryName;
  final String branchName;

  final SupplierForeignPreview? preview;

  /// What the supplier changed while looking at the preview, keyed by the row's
  /// position in the sheet. Kept apart from the file: the file is what their
  /// other system said, this is what they decided about it.
  final Map<int, SupplierForeignRowEdit> edits;

  final SupplierExcelImportResultEntity? result;

  final bool busy;

  /// True while the assistant is writing the missing descriptions. Kept apart
  /// from [busy] so the rows stay readable and editable while it works.
  final bool writingDescriptions;

  /// Whether the assistant is offered at all. Asked before the button is shown,
  /// rather than showing it and then explaining.
  final bool assistantAvailable;

  final String? error;

  const SupplierForeignImportState({
    required this.step,
    required this.fileName,
    required this.bytes,
    required this.sheets,
    required this.selectedSheet,
    required this.categoryName,
    required this.branchName,
    required this.preview,
    required this.edits,
    required this.result,
    required this.busy,
    required this.writingDescriptions,
    required this.assistantAvailable,
    required this.error,
  });

  const SupplierForeignImportState.initial()
      : step = SupplierForeignStep.pickFile,
        fileName = null,
        bytes = null,
        sheets = const [],
        selectedSheet = 0,
        categoryName = '',
        branchName = '',
        preview = null,
        edits = const {},
        result = null,
        busy = false,
        writingDescriptions = false,
        assistantAvailable = false,
        error = null;

  SupplierForeignSheetMapping? get sheet =>
      (selectedSheet >= 0 && selectedSheet < sheets.length)
          ? sheets[selectedSheet]
          : null;

  bool get canContinue => sheet?.hasName == true && !busy;

  /// Products the file left without a description. What the assistant is for.
  List<SupplierForeignProductPreview> get needingDescription {
    final products = preview?.products ?? const <SupplierForeignProductPreview>[];
    return products
        .where((p) => (p.description ?? '').trim().isEmpty)
        .toList();
  }

  /// Quantities were found but have nowhere to be counted yet.
  bool get stockNeedsBranch =>
      sheet?.hasStock == true && branchName.trim().isEmpty;

  SupplierForeignImportState copyWith({
    SupplierForeignStep? step,
    String? fileName,
    Uint8List? bytes,
    List<SupplierForeignSheetMapping>? sheets,
    int? selectedSheet,
    String? categoryName,
    String? branchName,
    SupplierForeignPreview? preview,
    Map<int, SupplierForeignRowEdit>? edits,
    SupplierExcelImportResultEntity? result,
    bool? busy,
    bool? writingDescriptions,
    bool? assistantAvailable,
    String? error,
    bool clearError = false,
  }) {
    return SupplierForeignImportState(
      step: step ?? this.step,
      fileName: fileName ?? this.fileName,
      bytes: bytes ?? this.bytes,
      sheets: sheets ?? this.sheets,
      selectedSheet: selectedSheet ?? this.selectedSheet,
      categoryName: categoryName ?? this.categoryName,
      branchName: branchName ?? this.branchName,
      preview: preview ?? this.preview,
      edits: edits ?? this.edits,
      result: result ?? this.result,
      busy: busy ?? this.busy,
      writingDescriptions: writingDescriptions ?? this.writingDescriptions,
      assistantAvailable: assistantAvailable ?? this.assistantAvailable,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SupplierForeignImportCubit extends Cubit<SupplierForeignImportState> {
  final PickSupplierExcelFileUseCase pickFile;
  final SuggestSupplierColumnMappingUseCase suggestMapping;
  final PreviewSupplierForeignFileUseCase previewFile;
  final ImportSupplierForeignFileUseCase importFile;
  final SupplierProductAiApiService assistant;

  SupplierForeignImportCubit({
    required this.pickFile,
    required this.suggestMapping,
    required this.previewFile,
    required this.importFile,
    required this.assistant,
  }) : super(const SupplierForeignImportState.initial());

  Future<void> chooseFile() async {
    emit(state.copyWith(busy: true, clearError: true));

    try {
      final picked = await pickFile();
      if (picked == null) {
        emit(state.copyWith(busy: false));
        return;
      }

      final sheets = await suggestMapping(
        fileName: picked.fileName,
        bytes: picked.bytes,
      );

      if (sheets.isEmpty) {
        emit(state.copyWith(busy: false, error: 'NO_SHEETS'));
        return;
      }

      emit(state.copyWith(
        step: SupplierForeignStep.confirmColumns,
        fileName: picked.fileName,
        bytes: picked.bytes,
        sheets: sheets,
        selectedSheet: 0,
        // A hand-kept file's tab name is usually already the category, so it is
        // offered rather than left for the supplier to retype.
        categoryName: sheets.first.hasCategory ? '' : sheets.first.sheetName,
        busy: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(busy: false, error: _messageOf(e)));
    }
  }

  void selectSheet(int index) {
    if (index == state.selectedSheet || index < 0 || index >= state.sheets.length) {
      return;
    }

    final sheet = state.sheets[index];
    emit(state.copyWith(
      selectedSheet: index,
      categoryName: sheet.hasCategory ? '' : sheet.sheetName,
      clearError: true,
    ));
  }

  void setColumnField(int columnIndex, SupplierForeignField field) {
    final sheet = state.sheet;
    if (sheet == null) return;

    final updated = [...state.sheets];
    updated[state.selectedSheet] = sheet.withColumn(columnIndex, field);

    emit(state.copyWith(sheets: updated, clearError: true));
  }

  void setCategoryName(String value) =>
      emit(state.copyWith(categoryName: value, clearError: true));

  void setBranchName(String value) =>
      emit(state.copyWith(branchName: value, clearError: true));

  Future<void> showPreview() async {
    final sheet = state.sheet;
    final bytes = state.bytes;
    final fileName = state.fileName;
    if (sheet == null || bytes == null || fileName == null) return;

    if (!sheet.hasName) {
      emit(state.copyWith(error: 'NEEDS_NAME'));
      return;
    }

    emit(state.copyWith(busy: true, clearError: true));

    try {
      final preview = await previewFile(
        fileName: fileName,
        bytes: bytes,
        mapping: sheet,
        categoryName: state.categoryName,
        branchName: state.branchName,
      );

      emit(state.copyWith(
        step: SupplierForeignStep.review,
        preview: preview,
        busy: false,
        clearError: true,
      ));

      // Whether to offer the assistant at all. A failure here only costs the
      // button, so it is never allowed to cost the preview.
      try {
        final available = await assistant.descriptionsAvailable();
        emit(state.copyWith(assistantAvailable: available));
      } catch (_) {
        emit(state.copyWith(assistantAvailable: false));
      }
    } catch (e) {
      emit(state.copyWith(busy: false, error: _messageOf(e)));
    }
  }

  /// Records a correction and re-reads the preview so the row shows it.
  Future<void> editRow(
    int row, {
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
  }) async {
    final existing = state.edits[row] ?? const SupplierForeignRowEdit();

    final edits = Map<int, SupplierForeignRowEdit>.from(state.edits);
    edits[row] = existing.copyWith(
      price: price,
      stock: stock,
      description: description,
      imageUrl: imageUrl,
    );

    emit(state.copyWith(edits: edits, clearError: true));
    await _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final sheet = state.sheet;
    final bytes = state.bytes;
    final fileName = state.fileName;
    if (sheet == null || bytes == null || fileName == null) return;

    emit(state.copyWith(busy: true, clearError: true));

    try {
      final preview = await previewFile(
        fileName: fileName,
        bytes: bytes,
        mapping: sheet,
        categoryName: state.categoryName,
        branchName: state.branchName,
        edits: state.edits,
      );

      emit(state.copyWith(preview: preview, busy: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(busy: false, error: _messageOf(e)));
    }
  }

  /// Has the assistant describe the products the file left blank.
  ///
  /// What comes back is kept as the supplier's own correction, exactly as if
  /// they had typed it -- so they can still change any of it, and it travels
  /// with the import the same way.
  Future<void> writeMissingDescriptions() async {
    final rows = state.needingDescription;
    if (rows.isEmpty || state.writingDescriptions) return;

    emit(state.copyWith(writingDescriptions: true, clearError: true));

    try {
      final written = await assistant.draftDescriptions([
        for (final p in rows)
          {'row': p.row, 'name': p.name, 'category': p.categoryName},
      ]);

      if (written.isEmpty) {
        emit(state.copyWith(writingDescriptions: false));
        return;
      }

      final edits = Map<int, SupplierForeignRowEdit>.from(state.edits);
      written.forEach((row, description) {
        if (description.trim().isEmpty) return;
        final existing = edits[row] ?? const SupplierForeignRowEdit();
        edits[row] = existing.copyWith(description: description.trim());
      });

      emit(state.copyWith(edits: edits, clearError: true));
      await _refreshPreview();
      emit(state.copyWith(writingDescriptions: false));
    } catch (e) {
      emit(state.copyWith(writingDescriptions: false, error: _messageOf(e)));
    }
  }

  void backToColumns() {
    emit(state.copyWith(step: SupplierForeignStep.confirmColumns, clearError: true));
  }

  Future<void> runImport() async {
    final sheet = state.sheet;
    final bytes = state.bytes;
    final fileName = state.fileName;
    final preview = state.preview;
    if (sheet == null || bytes == null || fileName == null || preview == null) return;

    if (preview.products.isEmpty) {
      emit(state.copyWith(error: 'NOTHING_TO_IMPORT'));
      return;
    }

    emit(state.copyWith(busy: true, clearError: true));

    try {
      final result = await importFile(
        fileName: fileName,
        bytes: bytes,
        mapping: sheet,
        categoryName: state.categoryName,
        branchName: state.branchName,
        totalRows: preview.products.length + preview.skippedRows,
        edits: state.edits,
      );

      emit(state.copyWith(
        step: SupplierForeignStep.done,
        result: result,
        busy: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(busy: false, error: _messageOf(e)));
    }
  }

  void clearError() {
    if (state.error == null) return;
    emit(state.copyWith(clearError: true));
  }

  static String _messageOf(Object e) =>
      e is AppException ? e.message : e.toString();
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';
import '../../domain/usecases/clear_supplier_excel_import_usecase.dart';
import '../../domain/usecases/import_supplier_excel_products_usecase.dart';
import '../../domain/usecases/parse_supplier_excel_file_usecase.dart';
import '../../domain/usecases/pick_supplier_excel_file_usecase.dart';
import '../../domain/usecases/validate_supplier_excel_rows_usecase.dart';
import 'supplier_excel_import_event.dart';
import 'supplier_excel_import_state.dart';

class SupplierExcelImportBloc
    extends Bloc<SupplierExcelImportEvent, SupplierExcelImportState> {
  final PickSupplierExcelFileUseCase pickSupplierExcelFileUseCase;
  final ParseSupplierExcelFileUseCase parseSupplierExcelFileUseCase;
  final ValidateSupplierExcelRowsUseCase validateSupplierExcelRowsUseCase;
  final ImportSupplierExcelProductsUseCase importSupplierExcelProductsUseCase;
  final ClearSupplierExcelImportUseCase clearSupplierExcelImportUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubCategoriesByCategoryUseCase getSubCategoriesByCategoryUseCase;
  final GetProductsUseCase getProductsUseCase;

  SupplierExcelImportBloc({
    required this.pickSupplierExcelFileUseCase,
    required this.parseSupplierExcelFileUseCase,
    required this.validateSupplierExcelRowsUseCase,
    required this.importSupplierExcelProductsUseCase,
    required this.clearSupplierExcelImportUseCase,
    required this.getCategoriesUseCase,
    required this.getSubCategoriesByCategoryUseCase,
    required this.getProductsUseCase,
  }) : super(SupplierExcelImportState.initial()) {
    on<SupplierExcelPickFileRequested>(_onPickFileRequested);
    on<SupplierExcelImportRequested>(_onImportRequested);
    on<SupplierExcelClearRequested>(_onClearRequested);
    on<SupplierExcelRowUpdated>(_onRowUpdated);
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
      final categories = await getCategoriesUseCase();
      final existingProducts = await getProductsUseCase();
      final subCategoriesByCategoryId =
          <String, List<SupplierSubCategoryEntity>>{};

      for (final category in categories) {
        subCategoriesByCategoryId[category.id] =
            await getSubCategoriesByCategoryUseCase(categoryId: category.id);
      }

      final validatedRows = _validateRows(
        parsedFile.rows,
        categories: categories,
        subCategoriesByCategoryId: subCategoriesByCategoryId,
        existingProducts: existingProducts,
      );

      emit(
        state.copyWith(
          isPickingOrParsing: false,
          fileName: parsedFile.fileName,
          rows: validatedRows,
          categories: categories,
          subCategoriesByCategoryId: subCategoriesByCategoryId,
          existingProducts: existingProducts,
          clearMessages: true,
          clearImportResult: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPickingOrParsing: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onImportRequested(
    SupplierExcelImportRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (!state.canImport) return;

    emit(
      state.copyWith(
        isImporting: true,
        clearMessages: true,
        clearImportResult: true,
      ),
    );

    try {
      final result = await importSupplierExcelProductsUseCase(rows: state.rows);

      final message = result.hasFailures
          ? 'Imported ${result.importedCount} products. ${result.failedCount} rows failed.'
          : 'Imported ${result.importedCount} products successfully.';

      emit(
        state.copyWith(
          isImporting: false,
          importResult: result,
          successMessage: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isImporting: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onRowUpdated(
    SupplierExcelRowUpdated event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    final updatedRows = state.rows.map((row) {
      if (row.rowNumber == event.row.rowNumber) return event.row;
      return row;
    }).toList();

    final validatedRows = _validateRows(
      updatedRows,
      categories: state.categories,
      subCategoriesByCategoryId: state.subCategoriesByCategoryId,
      existingProducts: state.existingProducts,
    );

    emit(
      state.copyWith(
        rows: validatedRows,
        clearMessages: true,
        clearImportResult: true,
      ),
    );
  }

  void _onClearRequested(
    SupplierExcelClearRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    clearSupplierExcelImportUseCase();
    emit(SupplierExcelImportState.initial());
  }

  List<SupplierExcelProductRowEntity> _validateRows(
    List<SupplierExcelProductRowEntity> rows, {
    required List<SupplierCategoryEntity> categories,
    required Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId,
    required List<ProductEntity> existingProducts,
  }) {
    return validateSupplierExcelRowsUseCase(
      rows: rows,
      categories: categories,
      subCategoriesByCategoryId: subCategoriesByCategoryId,
      existingProducts: existingProducts,
    );
  }
}

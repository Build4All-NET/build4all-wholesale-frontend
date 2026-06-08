import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../../domain/usecases/create_category_usecase.dart';
import '../../../domain/usecases/create_subcategory_usecase.dart';
import '../../../domain/usecases/delete_category_usecase.dart';
import '../../../domain/usecases/delete_subcategory_usecase.dart';
import '../../../domain/usecases/get_all_categories_usecase.dart';
import '../../../domain/usecases/get_all_subcategories_usecase.dart';
import '../../../domain/usecases/update_category_status_usecase.dart';
import '../../../domain/usecases/update_category_usecase.dart';
import '../../../domain/usecases/update_subcategory_status_usecase.dart';
import '../../../domain/usecases/update_subcategory_usecase.dart';
import 'supplier_catalog_event.dart';
import 'supplier_catalog_state.dart';

class SupplierCatalogBloc
    extends Bloc<SupplierCatalogEvent, SupplierCatalogState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final GetAllSubCategoriesUseCase getAllSubCategoriesUseCase;

  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final UpdateCategoryStatusUseCase updateCategoryStatusUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final UpdateSubCategoryUseCase updateSubCategoryUseCase;
  final UpdateSubCategoryStatusUseCase updateSubCategoryStatusUseCase;
  final DeleteSubCategoryUseCase deleteSubCategoryUseCase;

  SupplierCatalogBloc({
    required this.getAllCategoriesUseCase,
    required this.getAllSubCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.updateCategoryStatusUseCase,
    required this.deleteCategoryUseCase,
    required this.createSubCategoryUseCase,
    required this.updateSubCategoryUseCase,
    required this.updateSubCategoryStatusUseCase,
    required this.deleteSubCategoryUseCase,
  }) : super(SupplierCatalogState.initial()) {
    on<LoadSupplierCatalog>(_onLoadSupplierCatalog);
    on<RefreshSupplierCatalog>(_onRefreshSupplierCatalog);

    on<CreateCatalogCategoryRequested>(_onCreateCategoryRequested);
    on<UpdateCatalogCategoryRequested>(_onUpdateCategoryRequested);
    on<UpdateCatalogCategoryStatusRequested>(
      _onUpdateCategoryStatusRequested,
    );
    on<DeleteCatalogCategoryRequested>(_onDeleteCategoryRequested);

    on<CreateCatalogSubCategoryRequested>(_onCreateSubCategoryRequested);
    on<UpdateCatalogSubCategoryRequested>(_onUpdateSubCategoryRequested);
    on<UpdateCatalogSubCategoryStatusRequested>(
      _onUpdateSubCategoryStatusRequested,
    );
    on<DeleteCatalogSubCategoryRequested>(_onDeleteSubCategoryRequested);
  }

  Future<void> _onLoadSupplierCatalog(
    LoadSupplierCatalog event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _loadCatalog(emit);
  }

  Future<void> _onRefreshSupplierCatalog(
    RefreshSupplierCatalog event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(clearMessages: true));
    await _loadCatalog(emit);
  }

  Future<void> _loadCatalog(
    Emitter<SupplierCatalogState> emit,
  ) async {
    try {
      final categories = await getAllCategoriesUseCase();
      final subCategories = await getAllSubCategoriesUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          isSaving: false,
          categories: categories,
          subCategories: subCategories,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isSaving: false,
          error: _cleanError(e),
        ),
      );
    }
  }

  Future<void> _onCreateCategoryRequested(
    CreateCatalogCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await createCategoryUseCase(name: event.name);
      await _loadCatalogWithSuccess(emit, 'categoryAdded');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onUpdateCategoryRequested(
    UpdateCatalogCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await updateCategoryUseCase(
        categoryId: event.categoryId,
        name: event.name,
      );
      await _loadCatalogWithSuccess(emit, 'categoryUpdated');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onUpdateCategoryStatusRequested(
    UpdateCatalogCategoryStatusRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await updateCategoryStatusUseCase(
        categoryId: event.categoryId,
        status: event.status,
      );
      await _loadCatalogWithSuccess(emit, 'categoryStatusUpdated');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onDeleteCategoryRequested(
    DeleteCatalogCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await deleteCategoryUseCase(categoryId: event.categoryId);
      await _loadCatalogWithSuccess(emit, 'categoryDeleted');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onCreateSubCategoryRequested(
    CreateCatalogSubCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await createSubCategoryUseCase(
        categoryId: event.categoryId,
        name: event.name,
      );
      await _loadCatalogWithSuccess(emit, 'subCategoryAdded');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onUpdateSubCategoryRequested(
    UpdateCatalogSubCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await updateSubCategoryUseCase(
        subCategoryId: event.subCategoryId,
        name: event.name,
      );
      await _loadCatalogWithSuccess(emit, 'subCategoryUpdated');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onUpdateSubCategoryStatusRequested(
    UpdateCatalogSubCategoryStatusRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await updateSubCategoryStatusUseCase(
        subCategoryId: event.subCategoryId,
        status: event.status,
      );
      await _loadCatalogWithSuccess(emit, 'subCategoryStatusUpdated');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _onDeleteSubCategoryRequested(
    DeleteCatalogSubCategoryRequested event,
    Emitter<SupplierCatalogState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await deleteSubCategoryUseCase(subCategoryId: event.subCategoryId);
      await _loadCatalogWithSuccess(emit, 'subCategoryDeleted');
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: _cleanError(e)));
    }
  }

  Future<void> _loadCatalogWithSuccess(
    Emitter<SupplierCatalogState> emit,
    String message,
  ) async {
    final categories = await getAllCategoriesUseCase();
    final subCategories = await getAllSubCategoriesUseCase();

    emit(
      state.copyWith(
        isLoading: false,
        isSaving: false,
        categories: categories,
        subCategories: subCategories,
        successMessage: message,
      ),
    );
  }

  String _cleanError(Object error) {
    return AppErrorMapper.toMessage(error);
  }
}

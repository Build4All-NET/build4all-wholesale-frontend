import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../branches/domain/usecases/get_branches_usecase.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../domain/entities/photographed_supplier_product_entity.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/usecases/clear_supplier_excel_import_usecase.dart';
import '../../domain/usecases/create_supplier_photo_products_usecase.dart';
import '../../domain/usecases/draft_supplier_product_descriptions_usecase.dart';
import '../../domain/usecases/import_supplier_excel_products_usecase.dart';
import '../../domain/usecases/parse_supplier_excel_file_usecase.dart';
import '../../domain/usecases/pick_supplier_excel_file_usecase.dart';
import '../../domain/usecases/read_supplier_product_photos_usecase.dart';
import '../../domain/usecases/validate_supplier_excel_rows_usecase.dart';
import '../../../../../core/utils/picked_image_normalizer.dart';
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
  final ReadSupplierProductPhotosUseCase readSupplierProductPhotosUseCase;
  final CreateSupplierPhotoProductsUseCase createSupplierPhotoProductsUseCase;
  final DraftSupplierProductDescriptionsUseCase
      draftSupplierProductDescriptionsUseCase;

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
    required this.readSupplierProductPhotosUseCase,
    required this.createSupplierPhotoProductsUseCase,
    required this.draftSupplierProductDescriptionsUseCase,
  }) : super(SupplierExcelImportState.initial()) {
    on<SupplierExcelDownloadTemplateRequested>(_onDownloadTemplateRequested);
    on<SupplierExcelPickFileRequested>(_onPickFileRequested);
    on<SupplierExcelRowUpdated>(_onRowUpdated);
    on<SupplierExcelImportRequested>(_onImportRequested);
    on<SupplierExcelClearRequested>(_onClearRequested);
    on<SupplierExcelSourceChanged>(_onSourceChanged);
    on<SupplierPhotoCaptured>(_onPhotoCaptured);
    on<SupplierPhotoNameChanged>(_onPhotoNameChanged);
    on<SupplierPhotoCategoryChanged>(_onPhotoCategoryChanged);
    on<SupplierPhotoPriceChanged>(_onPhotoPriceChanged);
    on<SupplierPhotoMinimumOrderQuantityChanged>(_onPhotoMoqChanged);
    on<SupplierPhotoDescriptionChanged>(_onPhotoDescriptionChanged);
    on<SupplierPhotoRemoved>(_onPhotoRemoved);
    on<SupplierPhotoDraftDescriptionsPressed>(_onPhotoDraftDescriptions);
    on<SupplierPhotosImportPressed>(_onPhotosImportPressed);
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
        throw Exception(
          'The supplier template asset is not a valid .xlsx file.',
        );
      }

      final selectedPath = await FilePicker.saveFile(
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
        state.copyWith(isDownloadingTemplate: false, error: _message(error)),
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
    // A browser has no filesystem to write to: the picker already handed the
    // bytes to the browser as a download, under the file name we asked for, and
    // dart:io.File would throw here.
    if (kIsWeb) {
      return selectedPath;
    }

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
      emit(state.copyWith(error: _message(error), clearImportResult: true));
    }
  }

  Future<SupplierExcelParsedFileEntity> _validateFile(
    SupplierExcelParsedFileEntity parsedFile,
  ) async {
    final categories = await getCategoriesUseCase();
    final existingProducts = await getProductsUseCase();
    final existingBranches = await getBranchesUseCase();
    final subCategoriesByCategoryId =
        <String, List<SupplierSubCategoryEntity>>{};

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

    emit(state.copyWith(isImporting: true, clearMessages: true));

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
      emit(state.copyWith(isImporting: false, error: _message(error)));
    }
  }

  void _onClearRequested(
    SupplierExcelClearRequested event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    clearSupplierExcelImportUseCase();

    emit(SupplierExcelImportState.initial());
  }

  void _onSourceChanged(
    SupplierExcelSourceChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    if (event.source == state.source) return;

    // Everything read so far belongs to the other way of working; keeping it
    // would leave the supplier looking at a review of a file, or a batch of
    // photographs, they are no longer bringing in.
    emit(
      state.copyWith(
        source: event.source,
        clearParsedFile: true,
        clearImportResult: true,
        clearPhotos: true,
        clearMessages: true,
      ),
    );
  }

  /// How much a photograph is scaled down before it is sent. Big enough for
  /// the assistant to tell one product from another, small enough that a
  /// dozen of them go up over a supplier's connection rather than timing out
  /// on it.
  static const double _photoMaxWidth = 1280;
  static const int _photoQuality = 80;

  Future<void> _onPhotoCaptured(
    SupplierPhotoCaptured event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (state.readingPhotos) return;

    final picker = ImagePicker();

    try {
      final taken = <XFile>[];

      if (event.fromCamera) {
        // One shot per press: the camera hands back a single picture, and a
        // supplier walking a shelf presses again rather than choosing a
        // count first.
        final shot = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: _photoMaxWidth,
          imageQuality: _photoQuality,
        );
        if (shot != null) taken.add(shot);
      } else {
        taken.addAll(await picker.pickMultiImage(
          maxWidth: _photoMaxWidth,
          imageQuality: _photoQuality,
        ));
      }

      if (taken.isEmpty) return;

      final normalizedPaths = <String>[];
      for (final shot in taken) {
        normalizedPaths.add(await PickedImageNormalizer.toSrgb(shot.path));
      }

      emit(state.copyWith(readingPhotos: true, clearMessages: true));

      final read = await readSupplierProductPhotosUseCase(normalizedPaths);

      // Appended, not replaced: a supplier photographs a shelf at a time and
      // the batch before it is still theirs.
      final existing = state.photos;
      emit(
        state.copyWith(
          readingPhotos: false,
          photos: [
            ...existing,
            for (final product in read)
              PhotographedSupplierProductEntity(
                // Renumbered onto the end of what they already have, so a
                // correction lands on the product they are looking at.
                photoIndex: existing.length + product.photoIndex,
                galleryImageId: product.galleryImageId,
                imageUrl: product.imageUrl,
                name: product.name,
                category: product.category,
                price: '',
                minimumOrderQuantity: '5',
                description: '',
              ),
          ],
        ),
      );
    } catch (error) {
      emit(state.copyWith(readingPhotos: false, error: _message(error)));
    }
  }

  void _onPhotoNameChanged(
    SupplierPhotoNameChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(photos: _mapPhoto(
      event.photoIndex,
      (photo) => photo.copyWith(name: event.name),
    )));
  }

  void _onPhotoCategoryChanged(
    SupplierPhotoCategoryChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(photos: _mapPhoto(
      event.photoIndex,
      (photo) => photo.copyWith(category: event.category),
    )));
  }

  void _onPhotoPriceChanged(
    SupplierPhotoPriceChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(photos: _mapPhoto(
      event.photoIndex,
      (photo) => photo.copyWith(price: event.price),
    )));
  }

  void _onPhotoMoqChanged(
    SupplierPhotoMinimumOrderQuantityChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(photos: _mapPhoto(
      event.photoIndex,
      (photo) => photo.copyWith(
        minimumOrderQuantity: event.minimumOrderQuantity,
      ),
    )));
  }

  void _onPhotoDescriptionChanged(
    SupplierPhotoDescriptionChanged event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(photos: _mapPhoto(
      event.photoIndex,
      (photo) => photo.copyWith(description: event.description),
    )));
  }

  List<PhotographedSupplierProductEntity> _mapPhoto(
    int photoIndex,
    PhotographedSupplierProductEntity Function(PhotographedSupplierProductEntity)
        update,
  ) {
    return [
      for (final photo in state.photos)
        if (photo.photoIndex == photoIndex) update(photo) else photo,
    ];
  }

  void _onPhotoRemoved(
    SupplierPhotoRemoved event,
    Emitter<SupplierExcelImportState> emit,
  ) {
    emit(state.copyWith(
      photos: state.photos
          .where((photo) => photo.photoIndex != event.photoIndex)
          .toList(),
    ));
  }

  Future<void> _onPhotoDraftDescriptions(
    SupplierPhotoDraftDescriptionsPressed event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (state.draftingPhotoDescriptions) return;

    // Only the ones with a name and nothing said about them: one with no
    // name is not a product yet, and one the supplier already described is
    // not ours to replace.
    final photos = state.photosNeedingDescription;
    if (photos.isEmpty) return;

    emit(state.copyWith(draftingPhotoDescriptions: true, clearMessages: true));

    try {
      final written = await draftSupplierProductDescriptionsUseCase([
        for (final photo in photos)
          {
            'row': photo.photoIndex,
            'name': photo.name,
            'category': photo.category.trim().isEmpty ? null : photo.category,
          },
      ]);

      var updated = state.photos;
      written.forEach((photoIndex, description) {
        updated = [
          for (final photo in updated)
            if (photo.photoIndex == photoIndex)
              photo.copyWith(description: description)
            else
              photo,
        ];
      });

      emit(state.copyWith(
        draftingPhotoDescriptions: false,
        photos: updated,
      ));
    } catch (error) {
      emit(state.copyWith(
        draftingPhotoDescriptions: false,
        error: _message(error),
      ));
    }
  }

  Future<void> _onPhotosImportPressed(
    SupplierPhotosImportPressed event,
    Emitter<SupplierExcelImportState> emit,
  ) async {
    if (!state.canImportPhotos) return;

    emit(state.copyWith(creatingPhotoProducts: true, clearMessages: true));

    try {
      await createSupplierPhotoProductsUseCase([
        for (final photo in state.photos)
          {
            'name': photo.name.trim(),
            'description': photo.description.trim(),
            'categoryName': photo.category.trim(),
            'price': photo.price.trim(),
            'minimumOrderQuantity':
                int.tryParse(photo.minimumOrderQuantity.trim()),
            'imageUrl': photo.imageUrl,
          },
      ]);

      emit(state.copyWith(
        creatingPhotoProducts: false,
        clearPhotos: true,
        successMessage: 'supplierExcelImportSuccess',
      ));
    } catch (error) {
      emit(state.copyWith(
        creatingPhotoProducts: false,
        error: _message(error),
      ));
    }
  }

  String _message(Object error) {
    return AppErrorMapper.toMessage(error);
  }
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/photographed_supplier_product_entity.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_excel_section.dart';

/// Where the supplier's products are coming from.
///
/// Two genuinely different jobs: filling in a workbook, and photographing a
/// catalogue that has nothing written down at all. Asking once, up front,
/// keeps a supplier who has a file from reading steps that are not theirs.
/// How the supplier's products are getting into the catalogue.
///
/// [foreignFile] is a file their own system wrote, which nothing here can read
/// against the template -- it opens its own screen, where the columns are worked
/// out and confirmed before anything is created.
enum SupplierExcelSource { file, foreignFile, photos }

class SupplierExcelImportState extends Equatable {
  final bool isDownloadingTemplate;
  final bool isPickingOrParsing;
  final bool isImporting;
  final SupplierExcelParsedFileEntity? parsedFile;
  final String? error;
  final String? successMessage;
  final String? templateSavePath;
  final SupplierExcelImportResultEntity? importResult;

  /// Null until the supplier picks one. Nothing is preselected: a default
  /// would have them reading the steps of a way in they never chose.
  final SupplierExcelSource? source;

  /// True while photographs are being stored and read.
  final bool readingPhotos;

  /// The products photographed so far, in the order they were taken.
  final List<PhotographedSupplierProductEntity> photos;

  /// True while the assistant is describing the photographed products.
  final bool draftingPhotoDescriptions;

  /// True while the photographed products are being created.
  final bool creatingPhotoProducts;

  const SupplierExcelImportState({
    required this.isDownloadingTemplate,
    required this.isPickingOrParsing,
    required this.isImporting,
    this.parsedFile,
    this.error,
    this.successMessage,
    this.templateSavePath,
    this.importResult,
    this.source,
    this.readingPhotos = false,
    this.photos = const [],
    this.draftingPhotoDescriptions = false,
    this.creatingPhotoProducts = false,
  });

  factory SupplierExcelImportState.initial() {
    return const SupplierExcelImportState(
      isDownloadingTemplate: false,
      isPickingOrParsing: false,
      isImporting: false,
    );
  }

  String? get fileName => parsedFile?.fileName;
  bool get hasRows => parsedFile?.hasRows == true;
  bool get canImport => parsedFile?.canImport == true && !isImporting;

  int get totalRows => parsedFile?.totalRows ?? 0;
  int get validRowsCount => parsedFile?.validRows ?? 0;
  /// Total validation errors, not just number of invalid rows.
  /// This keeps the summary card consistent with the grouped issue list.
  int get errorRowsCount => parsedFile?.errorIssues ?? 0;

  /// Total validation warnings, not just number of rows with warnings.
  int get warningRowsCount => parsedFile?.warningIssues ?? 0;

  int sectionCount(SupplierExcelSection section) {
    return parsedFile?.rowsFor(section).length ?? 0;
  }

  /// Photographed products still waiting to be named. Nothing can be
  /// created with a blank name, so this is what stands between the
  /// supplier and the button.
  List<PhotographedSupplierProductEntity> get photosNeedingName =>
      photos.where((photo) => photo.needsName).toList();

  /// Named products with nothing written about them -- what the assistant
  /// would be asked to describe. One with no name is not a product yet, so
  /// it is not this list's to describe.
  List<PhotographedSupplierProductEntity> get photosNeedingDescription =>
      photos.where((p) => !p.needsName && p.needsDescription).toList();

  bool get canImportPhotos =>
      photos.isNotEmpty &&
      photosNeedingName.isEmpty &&
      photosNeedingDescription.isEmpty &&
      !creatingPhotoProducts &&
      !readingPhotos;

  SupplierExcelImportState copyWith({
    bool? isDownloadingTemplate,
    bool? isPickingOrParsing,
    bool? isImporting,
    SupplierExcelParsedFileEntity? parsedFile,
    String? error,
    String? successMessage,
    String? templateSavePath,
    SupplierExcelImportResultEntity? importResult,
    SupplierExcelSource? source,
    bool? readingPhotos,
    List<PhotographedSupplierProductEntity>? photos,
    bool? draftingPhotoDescriptions,
    bool? creatingPhotoProducts,
    bool clearMessages = false,
    bool clearTemplatePath = false,
    bool clearParsedFile = false,
    bool clearImportResult = false,
    bool clearPhotos = false,
  }) {
    return SupplierExcelImportState(
      isDownloadingTemplate:
          isDownloadingTemplate ?? this.isDownloadingTemplate,
      isPickingOrParsing: isPickingOrParsing ?? this.isPickingOrParsing,
      isImporting: isImporting ?? this.isImporting,
      parsedFile: clearParsedFile ? null : parsedFile ?? this.parsedFile,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
      templateSavePath:
          clearTemplatePath ? null : templateSavePath ?? this.templateSavePath,
      importResult: clearImportResult ? null : importResult ?? this.importResult,
      source: source ?? this.source,
      readingPhotos: readingPhotos ?? this.readingPhotos,
      photos: clearPhotos ? const [] : (photos ?? this.photos),
      draftingPhotoDescriptions:
          draftingPhotoDescriptions ?? this.draftingPhotoDescriptions,
      creatingPhotoProducts:
          creatingPhotoProducts ?? this.creatingPhotoProducts,
    );
  }

  @override
  List<Object?> get props => [
        isDownloadingTemplate,
        isPickingOrParsing,
        isImporting,
        parsedFile,
        error,
        successMessage,
        templateSavePath,
        importResult,
        source,
        readingPhotos,
        photos,
        draftingPhotoDescriptions,
        creatingPhotoProducts,
      ];
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/supplier_excel_section.dart';
import 'supplier_excel_import_state.dart' show SupplierExcelSource;

abstract class SupplierExcelImportEvent extends Equatable {
  const SupplierExcelImportEvent();

  @override
  List<Object?> get props => [];
}

class SupplierExcelDownloadTemplateRequested extends SupplierExcelImportEvent {
  const SupplierExcelDownloadTemplateRequested();
}

class SupplierExcelPickFileRequested extends SupplierExcelImportEvent {
  const SupplierExcelPickFileRequested();
}

class SupplierExcelRowUpdated extends SupplierExcelImportEvent {
  final SupplierExcelSection section;
  final int rowNumber;
  final Map<String, String> values;

  const SupplierExcelRowUpdated({
    required this.section,
    required this.rowNumber,
    required this.values,
  });

  @override
  List<Object?> get props => [section, rowNumber, values];
}

class SupplierExcelImportRequested extends SupplierExcelImportEvent {
  const SupplierExcelImportRequested();
}

class SupplierExcelClearRequested extends SupplierExcelImportEvent {
  const SupplierExcelClearRequested();
}

/// Switches between bringing a file and photographing the catalogue.
class SupplierExcelSourceChanged extends SupplierExcelImportEvent {
  final SupplierExcelSource source;
  const SupplierExcelSourceChanged(this.source);

  @override
  List<Object?> get props => [source];
}

/// Opens the camera, or the gallery, and reads whatever comes back.
class SupplierPhotoCaptured extends SupplierExcelImportEvent {
  /// True for the camera, false for pictures already on the device.
  final bool fromCamera;

  const SupplierPhotoCaptured({required this.fromCamera});

  @override
  List<Object?> get props => [fromCamera];
}

/// Corrects what one photographed product is called.
class SupplierPhotoNameChanged extends SupplierExcelImportEvent {
  final int photoIndex;
  final String name;

  const SupplierPhotoNameChanged({required this.photoIndex, required this.name});

  @override
  List<Object?> get props => [photoIndex, name];
}

/// Corrects the group one photographed product falls under.
class SupplierPhotoCategoryChanged extends SupplierExcelImportEvent {
  final int photoIndex;
  final String category;

  const SupplierPhotoCategoryChanged({
    required this.photoIndex,
    required this.category,
  });

  @override
  List<Object?> get props => [photoIndex, category];
}

class SupplierPhotoPriceChanged extends SupplierExcelImportEvent {
  final int photoIndex;
  final String price;

  const SupplierPhotoPriceChanged({required this.photoIndex, required this.price});

  @override
  List<Object?> get props => [photoIndex, price];
}

class SupplierPhotoMinimumOrderQuantityChanged extends SupplierExcelImportEvent {
  final int photoIndex;
  final String minimumOrderQuantity;

  const SupplierPhotoMinimumOrderQuantityChanged({
    required this.photoIndex,
    required this.minimumOrderQuantity,
  });

  @override
  List<Object?> get props => [photoIndex, minimumOrderQuantity];
}

class SupplierPhotoDescriptionChanged extends SupplierExcelImportEvent {
  final int photoIndex;
  final String description;

  const SupplierPhotoDescriptionChanged({
    required this.photoIndex,
    required this.description,
  });

  @override
  List<Object?> get props => [photoIndex, description];
}

/// Takes one photograph back off the list.
class SupplierPhotoRemoved extends SupplierExcelImportEvent {
  final int photoIndex;
  const SupplierPhotoRemoved(this.photoIndex);

  @override
  List<Object?> get props => [photoIndex];
}

/// Asks the assistant to describe the photographed products on screen.
class SupplierPhotoDraftDescriptionsPressed extends SupplierExcelImportEvent {
  const SupplierPhotoDraftDescriptionsPressed();
}

/// Creates the photographed products.
class SupplierPhotosImportPressed extends SupplierExcelImportEvent {
  const SupplierPhotosImportPressed();
}

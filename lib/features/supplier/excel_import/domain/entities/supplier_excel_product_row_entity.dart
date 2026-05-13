import '../../../products/domain/entities/product_entity.dart';

class SupplierExcelProductRowEntity {
  final int rowNumber;
  final String productName;
  final String description;
  final String categoryName;
  final String subCategoryName;
  final String priceText;
  final String moqText;
  final String statusText;
  final String? categoryId;
  final String? subCategoryId;
  final double? price;
  final int? minimumOrderQuantity;
  final ProductStatus? status;
  final List<String> errors;
  final List<String> warnings;

  SupplierExcelProductRowEntity({
    required this.rowNumber,
    required this.productName,
    required this.description,
    required this.categoryName,
    required this.subCategoryName,
    required this.priceText,
    required this.moqText,
    required this.statusText,
    this.categoryId,
    this.subCategoryId,
    this.price,
    this.minimumOrderQuantity,
    this.status,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasCatalogError {
    return errors.any((error) {
      final lower = error.toLowerCase();
      return lower.contains('category') || lower.contains('subcategory');
    });
  }

  SupplierExcelProductRowEntity copyWith({
    int? rowNumber,
    String? productName,
    String? description,
    String? categoryName,
    String? subCategoryName,
    String? priceText,
    String? moqText,
    String? statusText,
    String? categoryId,
    String? subCategoryId,
    double? price,
    int? minimumOrderQuantity,
    ProductStatus? status,
    List<String>? errors,
    List<String>? warnings,
    bool clearCategoryId = false,
    bool clearSubCategoryId = false,
    bool clearParsedPrice = false,
    bool clearParsedMoq = false,
    bool clearParsedStatus = false,
  }) {
    return SupplierExcelProductRowEntity(
      rowNumber: rowNumber ?? this.rowNumber,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      priceText: priceText ?? this.priceText,
      moqText: moqText ?? this.moqText,
      statusText: statusText ?? this.statusText,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      subCategoryId: clearSubCategoryId
          ? null
          : subCategoryId ?? this.subCategoryId,
      price: clearParsedPrice ? null : price ?? this.price,
      minimumOrderQuantity:
          clearParsedMoq ? null : minimumOrderQuantity ?? this.minimumOrderQuantity,
      status: clearParsedStatus ? null : status ?? this.status,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
    );
  }
}

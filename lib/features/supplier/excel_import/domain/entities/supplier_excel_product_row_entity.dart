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

  const SupplierExcelProductRowEntity({
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

  SupplierExcelProductRowEntity copyWith({
    String? categoryId,
    String? subCategoryId,
    double? price,
    int? minimumOrderQuantity,
    ProductStatus? status,
    List<String>? errors,
    List<String>? warnings,
    bool clearSubCategoryId = false,
  }) {
    return SupplierExcelProductRowEntity(
      rowNumber: rowNumber,
      productName: productName,
      description: description,
      categoryName: categoryName,
      subCategoryName: subCategoryName,
      priceText: priceText,
      moqText: moqText,
      statusText: statusText,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: clearSubCategoryId
          ? null
          : subCategoryId ?? this.subCategoryId,
      price: price ?? this.price,
      minimumOrderQuantity:
          minimumOrderQuantity ?? this.minimumOrderQuantity,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
    );
  }
}

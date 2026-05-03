import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.categoryName,
    super.subCategoryId,
    super.subCategoryName,
    required super.price,
    required super.minimumOrderQuantity,
    required super.status,
    super.imagePath,
    super.totalStock = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId'].toString(),
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryId: json['subCategoryId']?.toString(),
      subCategoryName: json['subCategoryName']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      minimumOrderQuantity:
          int.tryParse(json['minimumOrderQuantity']?.toString() ?? '0') ?? 0,
      status: _statusFromJson(json['status']),
      imagePath: json['imageUrl']?.toString(),
      totalStock: int.tryParse(json['totalStock']?.toString() ?? '0') ?? 0,
    );
  }

  static ProductStatus _statusFromJson(dynamic value) {
    final status = value?.toString().toUpperCase();

    if (status == 'INACTIVE') {
      return ProductStatus.inactive;
    }

    return ProductStatus.active;
  }

  static String statusToJson(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'ACTIVE';
      case ProductStatus.inactive:
        return 'INACTIVE';
    }
  }
}
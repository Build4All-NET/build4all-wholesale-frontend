enum ProductStatus {
  active,
  inactive,
}

class ProductEntity {
  final String id;
  final String name;
  final String description;

  final String categoryId;
  final String categoryName;

  final String? subCategoryId;
  final String? subCategoryName;

  final double price;
  final int minimumOrderQuantity;
  final ProductStatus status;
  final String? imagePath;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    required this.price,
    required this.minimumOrderQuantity,
    required this.status,
    this.imagePath,
  });
}
import '../../../products/domain/entities/product_entity.dart';

enum LowStockAlertLevel {
  outOfStock,
  critical,
  low,
}

class LowStockAlertEntity {
  final String inventoryId;

  final String branchId;
  final String branchName;
  final String branchCity;

  final String productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final int minimumOrderQuantity;
  final ProductStatus productStatus;
  final String? productImageUrl;

  final String categoryId;
  final String categoryName;

  final String? subCategoryId;
  final String? subCategoryName;

  final int stockQuantity;
  final LowStockAlertLevel alertLevel;

  const LowStockAlertEntity({
    required this.inventoryId,
    required this.branchId,
    required this.branchName,
    required this.branchCity,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.minimumOrderQuantity,
    required this.productStatus,
    this.productImageUrl,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    required this.stockQuantity,
    required this.alertLevel,
  });

  ProductEntity toProductEntity() {
    return ProductEntity(
      id: productId,
      name: productName,
      description: productDescription,
      categoryId: categoryId,
      categoryName: categoryName,
      subCategoryId: subCategoryId,
      subCategoryName: subCategoryName,
      price: productPrice,
      minimumOrderQuantity: minimumOrderQuantity,
      status: productStatus,
      imagePath: productImageUrl,
      totalStock: stockQuantity,
    );
  }
}
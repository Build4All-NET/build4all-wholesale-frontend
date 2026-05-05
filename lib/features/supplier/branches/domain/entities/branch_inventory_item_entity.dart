class BranchInventoryItemEntity {
  final String id;

  final String branchId;
  final String branchName;
  final String branchCity;

  final String productId;
  final String productName;

  final String categoryId;
  final String categoryName;

  final String? subCategoryId;
  final String? subCategoryName;

  final int stockQuantity;

  const BranchInventoryItemEntity({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.branchCity,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    required this.stockQuantity,
  });
}

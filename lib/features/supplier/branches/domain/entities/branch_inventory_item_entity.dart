class BranchInventoryItemEntity {
  final String id;
  final String branchId;
  final String productId;
  final String productName;
  final String categoryName;
  final int stockQuantity;

  const BranchInventoryItemEntity({
    required this.id,
    required this.branchId,
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.stockQuantity,
  });
}
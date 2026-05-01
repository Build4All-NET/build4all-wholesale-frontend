enum ProductStatus {
  active,
  lowStock,
  outOfStock,
}

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int minimumOrderQuantity;
  final int stockQuantity;
  final int beirutStock;
  final int tripoliStock;
  final int saidaStock;
  final ProductStatus status;
  final String? imagePath;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.minimumOrderQuantity,
    required this.stockQuantity,
    required this.beirutStock,
    required this.tripoliStock,
    required this.saidaStock,
    required this.status,
    this.imagePath,
  });
}
import '../domain/entities/product_entity.dart';

final List<ProductEntity> supplierMockProducts = [
  const ProductEntity(
    id: '1',
    name: 'Coca-Cola 24-Pack',
    description: 'Wholesale beverage pack for retailers.',
    categoryId: 'cat_food_beverages',
    categoryName: 'Food & Beverages',
    subCategoryId: 'sub_beverages',
    subCategoryName: 'Beverages',
    price: 18.99,
    minimumOrderQuantity: 10,
    status: ProductStatus.active,
  ),
];
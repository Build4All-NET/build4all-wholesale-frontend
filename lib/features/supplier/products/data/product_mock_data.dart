import '../domain/entities/product_entity.dart';

final List<ProductEntity> supplierMockProducts = [
  const ProductEntity(
    id: '1',
    name: 'Coca-Cola 24-Pack',
    description: 'Wholesale beverage pack for retailers.',
    category: 'Beverages',
    price: 18.99,
    minimumOrderQuantity: 10,
    stockQuantity: 845,
    beirutStock: 300,
    tripoliStock: 250,
    saidaStock: 295,
    status: ProductStatus.active,
  ),
];
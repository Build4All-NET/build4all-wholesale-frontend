import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/product_mock_store.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/product_card.dart';
import '../../../branches/data/branch_mock_store.dart';
class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  List<ProductEntity> get _products => ProductMockStore.products;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> get _filteredProducts {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query) ||
          (product.subCategoryName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addProduct() async {
    await context.push<ProductEntity>('/supplier-products/add');
    setState(() {});
  }

  Future<void> _editProduct(ProductEntity product) async {
    await context.push<ProductEntity>(
      '/supplier-products/edit',
      extra: product,
    );

    setState(() {});
  }

  void _deleteProduct(ProductEntity product) {
  setState(() {
    ProductMockStore.deleteProduct(product.id);
    BranchMockStore.deleteInventoryForProduct(product.id);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${product.name} deleted'),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: const Text(
          'Product Management',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _addProduct,
            icon: Icon(
              Icons.add_circle,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products, categories...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppThemeTokens.textSecondary,
                ),
                filled: true,
                fillColor: AppThemeTokens.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusSmall,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppThemeTokens.border),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return ProductCard(
                        product: product,
                        onEdit: () => _editProduct(product),
                        onDelete: () => _deleteProduct(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
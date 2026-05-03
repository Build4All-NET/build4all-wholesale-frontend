import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/product_card.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductRepository _productRepository = sl<ProductRepository>();

  Timer? _searchDebounce;

  bool _isLoading = true;
  bool _isDeleting = false;
  String _searchText = '';

  List<ProductEntity> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productRepository.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(e);
    }
  }

  Future<void> _searchProducts(String query) async {
    try {
      final products = query.trim().isEmpty
          ? await _productRepository.getProducts()
          : await _productRepository.searchProducts(query: query);

      if (!mounted) return;

      setState(() {
        _products = products;
      });
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
    });

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchProducts(value),
    );
  }

  Future<void> _addProduct() async {
    final result = await context.push<ProductEntity>('/supplier-products/add');

    if (result != null) {
      await _loadProducts();
    }
  }

  Future<void> _editProduct(ProductEntity product) async {
    final result = await context.push<ProductEntity>(
      '/supplier-products/edit',
      extra: product,
    );

    if (result != null) {
      await _loadProducts();
    }
  }

  Future<void> _deleteProduct(ProductEntity product) async {
    if (_isDeleting) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Product',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete ${product.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _productRepository.deleteProduct(productId: product.id);

      if (!mounted) return;

      setState(() {
        _products.removeWhere((item) => item.id == product.id);
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} deleted')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showError(e);
    }
  }

  void _showError(Object error) {
    final message = error is AppException
        ? error.message
        : error.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              onChanged: _onSearchChanged,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _searchText.trim().isEmpty
                            ? _loadProducts
                            : () => _searchProducts(_searchText),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];

                            return ProductCard(
                              product: product,
                              onEdit: () => _editProduct(product),
                              onDelete: () => _deleteProduct(product),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
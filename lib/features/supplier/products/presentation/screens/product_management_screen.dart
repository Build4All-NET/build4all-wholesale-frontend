import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_list/product_list_bloc.dart';
import '../bloc/product_list/product_list_event.dart';
import '../bloc/product_list/product_list_state.dart';
import '../widgets/product_card.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductListBloc _productListBloc = sl<ProductListBloc>();

  Timer? _searchDebounce;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _productListBloc.add(const LoadProducts());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _productListBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchText = value;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        _productListBloc.add(SearchProducts(value));
      },
    );
  }

  Future<void> _addProduct() async {
    final result = await context.push<ProductEntity>('/supplier-products/add');

    if (result != null) {
      _productListBloc.add(
        _searchText.trim().isEmpty
            ? const LoadProducts()
            : SearchProducts(_searchText),
      );
    }
  }

  Future<void> _editProduct(ProductEntity product) async {
    final result = await context.push<ProductEntity>(
      '/supplier-products/edit',
      extra: product,
    );

    if (result != null) {
      _productListBloc.add(
        _searchText.trim().isEmpty
            ? const LoadProducts()
            : SearchProducts(_searchText),
      );
    }
  }

  Future<void> _deleteProduct(ProductEntity product) async {
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

    _productListBloc.add(DeleteProductRequested(product.id));
  }

  Future<void> _refreshProducts() async {
    _productListBloc.add(
      _searchText.trim().isEmpty
          ? const LoadProducts()
          : SearchProducts(_searchText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductListBloc>.value(
      value: _productListBloc,
      child: BlocListener<ProductListBloc, ProductListState>(
        listenWhen: (previous, current) {
          return previous.error != current.error ||
              previous.successMessage != current.successMessage;
        },
        listener: (context, state) {
          if (state.error != null && state.error!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }

          if (state.successMessage != null &&
              state.successMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        child: BlocBuilder<ProductListBloc, ProductListState>(
          builder: (context, state) {
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
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.products.isEmpty
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
                                onRefresh: _refreshProducts,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: state.products.length,
                                  itemBuilder: (context, index) {
                                    final product = state.products[index];

                                    return ProductCard(
                                      product: product,
                                      onEdit: () => _editProduct(product),
                                      onDelete: state.isDeleting
                                          ? () {}
                                          : () => _deleteProduct(product),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
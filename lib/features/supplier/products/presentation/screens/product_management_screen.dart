import 'dart:async';

import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';
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
  ProductManagementScreen({super.key});

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
    _productListBloc.add(LoadProducts());
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
    _searchDebounce = Timer(Duration(milliseconds: 350), () {
      _productListBloc.add(SearchProducts(value));
    });
  }

  Future<void> _addProduct() async {
    final result = await context.push<ProductEntity>('/supplier-products/add');
    if (result != null) {
      _productListBloc.add(
        _searchText.trim().isEmpty ? LoadProducts() : SearchProducts(_searchText),
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
        _searchText.trim().isEmpty ? LoadProducts() : SearchProducts(_searchText),
      );
    }
  }

  Future<void> _deleteProduct(ProductEntity product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.deleteProductTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(context.l10n.deleteProductConfirmation(product.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.delete),
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
      _searchText.trim().isEmpty ? LoadProducts() : SearchProducts(_searchText),
    );
  }

  String _localizedSuccessMessage(BuildContext context, String message) {
    switch (message) {
      case 'productDeleted':
      case 'Product deleted':
        return context.l10n.productDeletedSuccessfully;
      default:
        return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(1.0)),
      child: BlocProvider<ProductListBloc>.value(
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
                SnackBar(
                  content: Text(
                    _localizedSuccessMessage(context, state.successMessage!),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ProductListBloc, ProductListState>(
            builder: (context, state) {
              final primaryColor = Theme.of(context).colorScheme.primary;

              return Scaffold(
                backgroundColor: AppThemeTokens.background,
                drawer: SupplierAppDrawer(),
                appBar: AppBar(
                  backgroundColor: AppThemeTokens.background,
                  elevation: 0,
                  centerTitle: true,
                  titleSpacing: 0,
                  title: Text(
                    context.l10n.productManagementTitle.replaceAll('\n', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 12),
                      child: InkWell(
                        onTap: _addProduct,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.20),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add, color: Colors.white, size: 25),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppThemeTokens.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchProductsHint,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppThemeTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppThemeTokens.textSecondary,
                            size: 24,
                          ),
                          filled: true,
                          fillColor: AppThemeTokens.inputFill,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: primaryColor, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: primaryColor, width: 1.6),
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppThemeTokens.border),
                    Expanded(
                      child: state.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : state.products.isEmpty
                              ? RefreshIndicator(
                                  onRefresh: _refreshProducts,
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.32,
                                      ),
                                      Center(
                                        child: Text(
                                          context.l10n.noProductsFound,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppThemeTokens.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshProducts,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
                                      final productCardHeight = crossAxisCount == 3 ? 310.0 : 295.0;

                                      return GridView.builder(
                                        physics: AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(16, 14, 16, 24),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 14,
                                          mainAxisExtent: productCardHeight,
                                        ),
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
      ),
    );
  }
}

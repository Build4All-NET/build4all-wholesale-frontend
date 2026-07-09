import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/branch_inventory_item_entity.dart';
import '../bloc/branch_inventory/branch_inventory_bloc.dart';
import '../bloc/branch_inventory/branch_inventory_event.dart';
import '../bloc/branch_inventory/branch_inventory_state.dart';
import '../widgets/branch_inventory_item_card.dart';

class BranchInventoryScreen extends StatefulWidget {
  final BranchEntity branch;

  BranchInventoryScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  final BranchInventoryBloc _branchInventoryBloc = sl<BranchInventoryBloc>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _branchInventoryBloc.add(
      LoadBranchInventory(branchId: widget.branch.id),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _branchInventoryBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  bool _matchesInventoryQuery(BranchInventoryItemEntity item) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return true;

    final searchableText = [
      item.productName,
      item.categoryName,
      item.subCategoryName ?? '',
      item.stockQuantity.toString(),
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  bool _matchesProductQuery(ProductEntity product, String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) return true;

    final searchableText = [
      product.name,
      product.description,
      product.categoryName,
      product.subCategoryName ?? '',
      product.price.toString(),
      product.minimumOrderQuantity.toString(),
    ].join(' ').toLowerCase();

    return searchableText.contains(normalizedQuery);
  }

  Future<void> _refreshInventory() async {
    _branchInventoryBloc.add(
      LoadBranchInventory(branchId: widget.branch.id),
    );
  }

  Future<void> _showAddProductStockDialog(
    BranchInventoryState state,
  ) async {
    if (state.isAssigning) return;

    final assignedProductIds = state.inventoryItems
        .map((inventoryItem) => inventoryItem.productId)
        .toSet();

    final availableProducts = state.products.where((product) {
      return !assignedProductIds.contains(product.id);
    }).toList();

    if (availableProducts.isEmpty) {
      AppToast.info(context, context.l10n.allProductsAssigned);
      return;
    }

    ProductEntity? selectedProduct = availableProducts.first;
    String productSearchQuery = '';
    final productSearchController = TextEditingController();
    final stockController = TextEditingController();

    final result = await showDialog<_AssignProductResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                context.l10n.assignProductToBranchTitle,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.productLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: productSearchController,
                      onChanged: (value) {
                        setDialogState(() {
                          productSearchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: context.l10n.searchProductsHint,
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        suffixIcon: productSearchQuery.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  productSearchController.clear();
                                  setDialogState(() {
                                    productSearchQuery = '';
                                  });
                                },
                                icon: Icon(Icons.close_rounded, size: 18),
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
                    SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final filteredProducts = availableProducts
                            .where(
                              (product) => _matchesProductQuery(
                                product,
                                productSearchQuery,
                              ),
                            )
                            .toList();

                        final safeSelectedProduct = filteredProducts.any(
                          (product) => product.id == selectedProduct?.id,
                        )
                            ? selectedProduct
                            : null;

                        if (filteredProducts.isEmpty) {
                          return _SearchEmptyCard(
                            text: 'No matching products found.',
                          );
                        }

                        return DropdownButtonFormField<ProductEntity>(
                          value: safeSelectedProduct,
                          items: filteredProducts.map((product) {
                            return DropdownMenuItem<ProductEntity>(
                              value: product,
                              child: Text(
                                product.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              selectedProduct = value;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppThemeTokens.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppThemeTokens.radiusSmall,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 14),
                    Text(
                      context.l10n.stockQuantityLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: context.l10n.stockQuantityHint,
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
                    SizedBox(height: 8),
                    Text(
                      context.l10n.inventoryRecordNote,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final stock = int.tryParse(stockController.text.trim());

                    final product = selectedProduct;

                    if (product == null ||
                        !_matchesProductQuery(product, productSearchQuery) ||
                        stock == null ||
                        stock <= 0 ||
                        stock > 1000000) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _AssignProductResult(
                        product: product,
                        stockQuantity: stock,
                      ),
                    );
                  },
                  child: Text(context.l10n.assignButton),
                ),
              ],
            );
          },
        );
      },
    );

    productSearchController.dispose();
    stockController.dispose();

    if (result == null) return;

    _branchInventoryBloc.add(
      AssignProductToBranchRequested(
        branchId: widget.branch.id,
        productId: result.product.id,
        stockQuantity: result.stockQuantity,
      ),
    );
  }

  Future<void> _showUpdateStockDialog(
    BranchInventoryItemEntity item,
  ) async {
    final controller = TextEditingController(
      text: item.stockQuantity.toString(),
    );

    final newStock = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.updateStockTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.productName,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.stockQuantityFieldLabel,
                  hintText: context.l10n.stockQuantityUpdateHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());

                if (value == null || value < 0 || value > 1000000) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(context.l10n.updateButton),
            ),
          ],
        );
      },
    );

    if (newStock == null) return;

    _branchInventoryBloc.add(
      UpdateBranchInventoryStockRequested(
        branchId: widget.branch.id,
        inventoryId: item.id,
        stockQuantity: newStock,
      ),
    );
  }

  Future<void> _deleteInventoryItem(
    BranchInventoryItemEntity item,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.removeProductFromBranchTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            context.l10n.removeProductFromBranchConfirmation(item.productName, widget.branch.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.removeButton),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    _branchInventoryBloc.add(
      DeleteBranchInventoryItemRequested(
        branchId: widget.branch.id,
        inventoryId: item.id,
      ),
    );
  }


  String _localizedSuccessMessage(BuildContext context, String message) {
    switch (message) {
      case 'productAssignedToBranch':
      case 'Product assigned to branch':
        return context.l10n.productAssignedToBranchSuccessfully;
      case 'stockUpdated':
      case 'Stock updated':
        return context.l10n.stockUpdatedSuccessfully;
      case 'inventoryItemRemoved':
      case 'Inventory item removed':
        return context.l10n.inventoryItemRemovedSuccessfully;
      default:
        return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BranchInventoryBloc>.value(
      value: _branchInventoryBloc,
      child: BlocListener<BranchInventoryBloc, BranchInventoryState>(
        listenWhen: (previous, current) {
          return previous.error != current.error ||
              previous.successMessage != current.successMessage;
        },
        listener: (context, state) {
          if (state.error != null && state.error!.trim().isNotEmpty) {
            AppToast.error(context, state.error!);
          }

          if (state.successMessage != null &&
              state.successMessage!.trim().isNotEmpty) {
            AppToast.success(
              context,
              _localizedSuccessMessage(context, state.successMessage!),
            );
          }
        },
        child: BlocBuilder<BranchInventoryBloc, BranchInventoryState>(
          builder: (context, state) {
            final primaryColor = Theme.of(context).colorScheme.primary;
            final filteredInventoryItems = state.inventoryItems
                .where(_matchesInventoryQuery)
                .toList();
            final hasSearchQuery = _searchQuery.trim().isNotEmpty;

            return Scaffold(
              backgroundColor: AppThemeTokens.background,
              appBar: AppBar(
                backgroundColor: AppThemeTokens.background,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.branchInventoryTitle(widget.branch.name),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.branch.city,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: state.isAssigning
                        ? null
                        : () => _showAddProductStockDialog(state),
                    icon: Icon(
                      Icons.add_circle,
                      color: primaryColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              body: state.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : state.inventoryItems.isEmpty
                      ? _EmptyInventoryView(
                          onAssignProduct: () =>
                              _showAddProductStockDialog(state),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshInventory,
                          child: ListView(
                            padding: EdgeInsets.all(16),
                            children: [
                              _InventorySearchField(
                                controller: _searchController,
                                hintText: context.l10n.searchProductsHint,
                                onChanged: _onSearchChanged,
                              ),
                              SizedBox(height: 14),
                              if (filteredInventoryItems.isEmpty &&
                                  hasSearchQuery)
                                _SearchEmptyCard(
                                  text: 'No matching inventory items found.',
                                )
                              else
                                ...filteredInventoryItems.map((item) {
                                  return BranchInventoryItemCard(
                                    item: item,
                                    onUpdate: () =>
                                        _showUpdateStockDialog(item),
                                    onDelete: state.isDeleting
                                        ? () {}
                                        : () => _deleteInventoryItem(item),
                                  );
                                }),
                            ],
                          ),
                        ),
            );
          },
        ),
      ),
    );
  }
}

class _InventorySearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _InventorySearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search_rounded, size: 20),
        suffixIcon: controller.text.trim().isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SearchEmptyCard extends StatelessWidget {
  final String text;

  const _SearchEmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: primaryColor, size: 32),
          SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignProductResult {
  final ProductEntity product;
  final int stockQuantity;

  _AssignProductResult({
    required this.product,
    required this.stockQuantity,
  });
}

class _EmptyInventoryView extends StatelessWidget {
  final VoidCallback onAssignProduct;

  _EmptyInventoryView({
    required this.onAssignProduct,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 58,
              color: primaryColor,
            ),
            SizedBox(height: 14),
            Text(
              context.l10n.noInventoryFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.assignProductsToBranchEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
            SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAssignProduct,
              icon: Icon(Icons.add),
              label: Text(
                context.l10n.assignProductButton,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

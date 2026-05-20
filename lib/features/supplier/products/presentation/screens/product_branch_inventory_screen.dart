import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/domain/entities/branch_inventory_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_branch_inventory/product_branch_inventory_bloc.dart';
import '../bloc/product_branch_inventory/product_branch_inventory_event.dart';
import '../bloc/product_branch_inventory/product_branch_inventory_state.dart';

class ProductBranchInventoryScreen extends StatefulWidget {
  final ProductEntity product;

  ProductBranchInventoryScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductBranchInventoryScreen> createState() =>
      _ProductBranchInventoryScreenState();
}

class _ProductBranchInventoryScreenState
    extends State<ProductBranchInventoryScreen> {
  final ProductBranchInventoryBloc _productBranchInventoryBloc =
      sl<ProductBranchInventoryBloc>();

  @override
  void initState() {
    super.initState();

    _productBranchInventoryBloc.add(
      LoadProductBranchInventory(product: widget.product),
    );
  }

  @override
  void dispose() {
    _productBranchInventoryBloc.close();
    super.dispose();
  }

  Future<void> _refreshInventory() async {
    _productBranchInventoryBloc.add(
      LoadProductBranchInventory(product: widget.product),
    );
  }

  BranchInventoryItemEntity? _getInventoryForBranch({
    required ProductBranchInventoryState state,
    required String branchId,
  }) {
    try {
      return state.productInventory.firstWhere(
        (item) => item.branchId == branchId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _showStockDialog({
    required BranchEntity branch,
    BranchInventoryItemEntity? inventoryItem,
  }) async {
    final isUpdate = inventoryItem != null;

    final controller = TextEditingController(
      text: isUpdate ? inventoryItem.stockQuantity.toString() : '',
    );

    final stockQuantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          title: Text(
            isUpdate ? context.l10n.updateBranchStockTitle : context.l10n.assignStockToBranchTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              _DialogInfoRow(
                label: context.l10n.productLabel,
                value: widget.product.name,
              ),
              SizedBox(height: 8),
              _DialogInfoRow(
                label: context.l10n.branchLabelPlain,
                value: branch.name,
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.stockQuantityFieldLabel,
                  hintText: context.l10n.stockQuantityUpdateHint,
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
                context.l10n.stockSavedToBranchInventoryNote,
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
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
                final value = int.tryParse(controller.text.trim());

                if (value == null || value < 0 || value > 1000000) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: Text(isUpdate ? context.l10n.updateButton : context.l10n.assignButton),
            ),
          ],
        );
      },
    );

    if (stockQuantity == null) return;

    if (isUpdate) {
      _productBranchInventoryBloc.add(
        UpdateProductBranchStockRequested(
          product: widget.product,
          inventoryId: inventoryItem.id,
          stockQuantity: stockQuantity,
        ),
      );
    } else {
      _productBranchInventoryBloc.add(
        AssignProductStockToBranchRequested(
          product: widget.product,
          branchId: branch.id,
          stockQuantity: stockQuantity,
        ),
      );
    }
  }

  Future<void> _deleteInventoryItem({
    required BranchEntity branch,
    required BranchInventoryItemEntity inventoryItem,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          title: Text(
            context.l10n.removeProductFromBranchTitle,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            context.l10n.removeProductFromBranchConfirmation(widget.product.name, branch.name),
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

    _productBranchInventoryBloc.add(
      DeleteProductBranchInventoryItemRequested(
        product: widget.product,
        inventoryId: inventoryItem.id,
      ),
    );
  }


  String _localizedSuccessMessage(BuildContext context, String message) {
    switch (message) {
      case 'stockAssigned':
      case 'Stock assigned':
        return context.l10n.stockAssignedSuccessfully;
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
    return BlocProvider<ProductBranchInventoryBloc>.value(
      value: _productBranchInventoryBloc,
      child:
          BlocListener<ProductBranchInventoryBloc, ProductBranchInventoryState>(
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
              SnackBar(content: Text(_localizedSuccessMessage(context, state.successMessage!))),
            );
          }
        },
        child:
            BlocBuilder<ProductBranchInventoryBloc, ProductBranchInventoryState>(
          builder: (context, state) {
            final primaryColor = Theme.of(context).colorScheme.primary;

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
                      context.l10n.productBranchStockTitle,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.product.name,
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
                    onPressed: _refreshInventory,
                    icon: Icon(
                      Icons.refresh,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              body: state.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshInventory,
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          _ProductStockSummaryCard(
                            product: widget.product,
                            totalBranches: state.branches.length,
                            assignedBranches: state.productInventory.length,
                            totalStock: state.totalStock,
                          ),
                          SizedBox(height: 16),
                          Text(
                            context.l10n.stockByBranchTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppThemeTokens.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            context.l10n.productBranchStockExplanation,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (state.branches.isEmpty)
                            _EmptyBranchesCard()
                          else
                            ...state.branches.map((branch) {
                              final inventoryItem = _getInventoryForBranch(
                                state: state,
                                branchId: branch.id,
                              );

                              return _ProductBranchStockCard(
                                branch: branch,
                                inventoryItem: inventoryItem,
                                onAssignOrUpdate:
                                    state.isSaving || state.isDeleting
                                        ? () {}
                                        : () => _showStockDialog(
                                              branch: branch,
                                              inventoryItem: inventoryItem,
                                            ),
                                onDelete: inventoryItem == null ||
                                        state.isSaving ||
                                        state.isDeleting
                                    ? null
                                    : () => _deleteInventoryItem(
                                          branch: branch,
                                          inventoryItem: inventoryItem,
                                        ),
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

class _ProductStockSummaryCard extends StatelessWidget {
  final ProductEntity product;
  final int totalBranches;
  final int assignedBranches;
  final int totalStock;

  _ProductStockSummaryCard({
    required this.product,
    required this.totalBranches,
    required this.assignedBranches,
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.12),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _SummaryChip(
                label: context.l10n.totalStockLabel,
                value: totalStock.toString(),
              ),
              SizedBox(width: 8),
              _SummaryChip(
                label: context.l10n.branchesLabel,
                value: '$assignedBranches/$totalBranches',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  _SummaryChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductBranchStockCard extends StatelessWidget {
  final BranchEntity branch;
  final BranchInventoryItemEntity? inventoryItem;
  final VoidCallback onAssignOrUpdate;
  final VoidCallback? onDelete;

  _ProductBranchStockCard({
    required this.branch,
    required this.inventoryItem,
    required this.onAssignOrUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasStockRecord = inventoryItem != null;
    final stockQuantity = inventoryItem?.stockQuantity ?? 0;

    final isLowStock = hasStockRecord && stockQuantity <= 50;
    final stockColor = !hasStockRecord
        ? AppThemeTokens.textSecondary
        : isLowStock
            ? AppThemeTokens.error
            : Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${branch.city} • ${branch.address}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hasStockRecord
                      ? context.l10n.stockWithQuantity(stockQuantity)
                      : context.l10n.notAssignedYet,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: stockColor,
                  ),
                ),
              ),
              Spacer(),
              OutlinedButton.icon(
                onPressed: onAssignOrUpdate,
                icon: Icon(
                  hasStockRecord
                      ? Icons.edit_outlined
                      : Icons.add_circle_outline,
                  size: 18,
                ),
                label: Text(
                  hasStockRecord ? context.l10n.updateButton : context.l10n.assignButton,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.textPrimary,
                  side: BorderSide(color: AppThemeTokens.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                ),
              ),
              if (hasStockRecord) ...[
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.error,
                    side: BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyBranchesCard extends StatelessWidget {
  _EmptyBranchesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: AppThemeTokens.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            context.l10n.noBranchesFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            context.l10n.createBranchFirst,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  _DialogInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

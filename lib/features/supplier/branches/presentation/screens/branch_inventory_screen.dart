import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../products/data/product_mock_store.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/branch_mock_store.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/branch_inventory_item_entity.dart';
import '../widgets/branch_inventory_item_card.dart';

class BranchInventoryScreen extends StatefulWidget {
  final BranchEntity branch;

  const BranchInventoryScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchInventoryScreen> createState() => _BranchInventoryScreenState();
}

class _BranchInventoryScreenState extends State<BranchInventoryScreen> {
  Future<void> _showAddProductStockDialog() async {
    final availableProducts = ProductMockStore.products.where((product) {
      return !BranchMockStore.branchHasProduct(
        branchId: widget.branch.id,
        productId: product.id,
      );
    }).toList();

    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All available products are already assigned to this branch',
          ),
        ),
      );
      return;
    }

    ProductEntity? selectedProduct = availableProducts.first;
    final stockController = TextEditingController();

    final result = await showDialog<_AssignProductResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Assign Product to Branch',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ProductEntity>(
                      initialValue: selectedProduct,
                      items: availableProducts.map((product) {
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
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Stock Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g., 100',
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
                    const SizedBox(height: 8),
                    const Text(
                      'This creates an inventory record for this branch and product.',
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final stock = int.tryParse(stockController.text.trim());

                    if (selectedProduct == null ||
                        stock == null ||
                        stock <= 0 ||
                        stock > 1000000) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _AssignProductResult(
                        product: selectedProduct!,
                        stockQuantity: stock,
                      ),
                    );
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    BranchMockStore.addInventoryItemToBranch(
      branchId: widget.branch.id,
      productId: result.product.id,
      productName: result.product.name,
      categoryName: result.product.subCategoryName == null ||
              result.product.subCategoryName!.trim().isEmpty
          ? result.product.categoryName
          : '${result.product.categoryName} • ${result.product.subCategoryName}',
      stockQuantity: result.stockQuantity,
    );

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${result.product.name} assigned to ${widget.branch.name}'),
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
          title: const Text(
            'Update Stock',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock quantity',
                  hintText: 'e.g., 500',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());

                if (value == null || value < 0 || value > 1000000) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (newStock == null) return;

    BranchMockStore.updateInventoryStock(
      inventoryItemId: item.id,
      newStockQuantity: newStock,
    );

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.productName} stock updated'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItems = BranchMockStore.getInventoryByBranchId(
      widget.branch.id,
    );

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.branch.name} Inventory',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.branch.city,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddProductStockDialog,
            icon: Icon(
              Icons.add_circle,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: inventoryItems.isEmpty
          ? _EmptyInventoryView(
              onAssignProduct: _showAddProductStockDialog,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];

                return BranchInventoryItemCard(
                  item: item,
                  onUpdate: () => _showUpdateStockDialog(item),
                );
              },
            ),
    );
  }
}

class _AssignProductResult {
  final ProductEntity product;
  final int stockQuantity;

  const _AssignProductResult({
    required this.product,
    required this.stockQuantity,
  });
}

class _EmptyInventoryView extends StatelessWidget {
  final VoidCallback onAssignProduct;

  const _EmptyInventoryView({
    required this.onAssignProduct,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 58,
              color: primaryColor,
            ),
            const SizedBox(height: 14),
            const Text(
              'No inventory found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Assign products to this branch to start tracking stock.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAssignProduct,
              icon: const Icon(Icons.add),
              label: const Text(
                'Assign Product',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
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
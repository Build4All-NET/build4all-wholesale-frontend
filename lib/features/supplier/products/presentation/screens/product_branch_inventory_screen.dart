import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/domain/entities/branch_inventory_item_entity.dart';
import '../../../branches/domain/repositories/branch_inventory_repository.dart';
import '../../../branches/domain/repositories/branch_repository.dart';
import '../../domain/entities/product_entity.dart';

class ProductBranchInventoryScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductBranchInventoryScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductBranchInventoryScreen> createState() =>
      _ProductBranchInventoryScreenState();
}

class _ProductBranchInventoryScreenState
    extends State<ProductBranchInventoryScreen> {
  final BranchRepository _branchRepository = sl<BranchRepository>();
  final BranchInventoryRepository _inventoryRepository =
      sl<BranchInventoryRepository>();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  List<BranchEntity> _branches = [];
  List<BranchInventoryItemEntity> _productInventory = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final branches = await _branchRepository.getBranches();
      final productInventory = await _inventoryRepository.getInventoryByProduct(
        productId: widget.product.id,
      );

      if (!mounted) return;

      setState(() {
        _branches = branches;
        _productInventory = productInventory;
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

  BranchInventoryItemEntity? _getInventoryForBranch(String branchId) {
    try {
      return _productInventory.firstWhere(
        (item) => item.branchId == branchId,
      );
    } catch (_) {
      return null;
    }
  }

  int get _totalStock {
    return _productInventory.fold<int>(
      0,
      (sum, item) => sum + item.stockQuantity,
    );
  }

  Future<void> _showStockDialog({
    required BranchEntity branch,
    BranchInventoryItemEntity? inventoryItem,
  }) async {
    if (_isSaving) return;

    final isUpdate = inventoryItem != null;

    final controller = TextEditingController(
      text: isUpdate ? inventoryItem.stockQuantity.toString() : '',
    );

    final stockQuantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isUpdate ? 'Update Branch Stock' : 'Assign Stock to Branch',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogInfoRow(
                label: 'Product',
                value: widget.product.name,
              ),
              const SizedBox(height: 8),
              _DialogInfoRow(
                label: 'Branch',
                value: branch.name,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock quantity',
                  hintText: 'e.g., 250',
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
                'Stock is saved directly in Branch Inventory. You do not need to update the product details again.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
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
              child: Text(isUpdate ? 'Update' : 'Assign'),
            ),
          ],
        );
      },
    );

    if (stockQuantity == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (isUpdate) {
        await _inventoryRepository.updateStock(
          inventoryId: inventoryItem.id,
          stockQuantity: stockQuantity,
        );
      } else {
        await _inventoryRepository.assignProductToBranch(
          branchId: branch.id,
          productId: widget.product.id,
          stockQuantity: stockQuantity,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      await _loadInitialData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdate
                ? '${branch.name} stock updated'
                : '${widget.product.name} assigned to ${branch.name}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError(e);
    }
  }

  Future<void> _deleteInventoryItem({
    required BranchEntity branch,
    required BranchInventoryItemEntity inventoryItem,
  }) async {
    if (_isDeleting) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Product from Branch',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to remove ${widget.product.name} from ${branch.name} inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
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
      await _inventoryRepository.deleteInventoryItem(
        inventoryId: inventoryItem.id,
      );

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      await _loadInitialData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} removed from ${branch.name}'),
        ),
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
            const Text(
              'Product Branch Stock',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.product.name,
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
            onPressed: _loadInitialData,
            icon: Icon(
              Icons.refresh,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ProductStockSummaryCard(
                    product: widget.product,
                    totalBranches: _branches.length,
                    assignedBranches: _productInventory.length,
                    totalStock: _totalStock,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stock by Branch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Update this product stock directly per branch. This saves to Branch Inventory, not Product details.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_branches.isEmpty)
                    const _EmptyBranchesCard()
                  else
                    ..._branches.map((branch) {
                      final inventoryItem = _getInventoryForBranch(branch.id);

                      return _ProductBranchStockCard(
                        branch: branch,
                        inventoryItem: inventoryItem,
                        onAssignOrUpdate: () => _showStockDialog(
                          branch: branch,
                          inventoryItem: inventoryItem,
                        ),
                        onDelete: inventoryItem == null
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
  }
}

class _ProductStockSummaryCard extends StatelessWidget {
  final ProductEntity product;
  final int totalBranches;
  final int assignedBranches;
  final int totalStock;

  const _ProductStockSummaryCard({
    required this.product,
    required this.totalBranches,
    required this.assignedBranches,
    required this.totalStock,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryChip(
                label: 'Total Stock',
                value: totalStock.toString(),
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: 'Branches',
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

  const _SummaryChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
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

  const _ProductBranchStockCard({
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${branch.city} • ${branch.address}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hasStockRecord
                      ? 'Stock: $stockQuantity'
                      : 'Not assigned yet',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: stockColor,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onAssignOrUpdate,
                icon: Icon(
                  hasStockRecord
                      ? Icons.edit_outlined
                      : Icons.add_circle_outline,
                  size: 18,
                ),
                label: Text(
                  hasStockRecord ? 'Update' : 'Assign',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.textPrimary,
                  side: const BorderSide(color: AppThemeTokens.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusSmall,
                    ),
                  ),
                ),
              ),
              if (hasStockRecord) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.error,
                    side: const BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusSmall,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: const Icon(Icons.delete_outline, size: 20),
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
  const _EmptyBranchesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: AppThemeTokens.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No branches found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Create a branch first, then assign product stock.',
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

  const _DialogInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

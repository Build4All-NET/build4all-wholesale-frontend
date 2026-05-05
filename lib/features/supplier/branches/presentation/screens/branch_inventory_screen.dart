import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/branch_inventory_item_entity.dart';
import '../../domain/repositories/branch_inventory_repository.dart';
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
  final BranchInventoryRepository _inventoryRepository =
      sl<BranchInventoryRepository>();

  final ProductRepository _productRepository = sl<ProductRepository>();

  bool _isLoading = true;
  bool _isAssigning = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  List<BranchInventoryItemEntity> _inventoryItems = [];
  List<ProductEntity> _products = [];

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
      final inventoryItems = await _inventoryRepository.getInventoryByBranch(
        branchId: widget.branch.id,
      );

      final products = await _productRepository.getProducts();

      if (!mounted) return;

      setState(() {
        _inventoryItems = inventoryItems;
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

  Future<void> _showAddProductStockDialog() async {
    if (_isAssigning) return;

    final assignedProductIds = _inventoryItems
        .map((inventoryItem) => inventoryItem.productId)
        .toSet();

    final availableProducts = _products.where((product) {
      return !assignedProductIds.contains(product.id);
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

    setState(() {
      _isAssigning = true;
    });

    try {
      await _inventoryRepository.assignProductToBranch(
        branchId: widget.branch.id,
        productId: result.product.id,
        stockQuantity: result.stockQuantity,
      );

      if (!mounted) return;

      setState(() {
        _isAssigning = false;
      });

      await _loadInitialData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${result.product.name} assigned to ${widget.branch.name}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAssigning = false;
      });

      _showError(e);
    }
  }

  Future<void> _showUpdateStockDialog(
    BranchInventoryItemEntity item,
  ) async {
    if (_isUpdating) return;

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

    setState(() {
      _isUpdating = true;
    });

    try {
      await _inventoryRepository.updateStock(
        inventoryId: item.id,
        stockQuantity: newStock,
      );

      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      await _loadInitialData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.productName} stock updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      _showError(e);
    }
  }

  Future<void> _deleteInventoryItem(
    BranchInventoryItemEntity item,
  ) async {
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
            'Are you sure you want to remove ${item.productName} from ${widget.branch.name} inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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
        inventoryId: item.id,
      );

      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      await _loadInitialData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.productName} removed from inventory'),
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
            onPressed: _isAssigning ? null : _showAddProductStockDialog,
            icon: Icon(
              Icons.add_circle,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inventoryItems.isEmpty
              ? _EmptyInventoryView(
                  onAssignProduct: _showAddProductStockDialog,
                )
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _inventoryItems.length,
                    itemBuilder: (context, index) {
                      final item = _inventoryItems[index];

                      return BranchInventoryItemCard(
                        item: item,
                        onUpdate: () => _showUpdateStockDialog(item),
                        onDelete: () => _deleteInventoryItem(item),
                      );
                    },
                  ),
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
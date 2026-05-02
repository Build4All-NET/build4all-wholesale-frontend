import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/branch_inventory_item_entity.dart';

class BranchInventoryItemCard extends StatelessWidget {
  final BranchInventoryItemEntity item;
  final VoidCallback onUpdate;

  const BranchInventoryItemCard({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = item.stockQuantity <= 50;
    final stockColor = isLowStock
        ? AppThemeTokens.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Stock: ${item.stockQuantity}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: stockColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Update',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeTokens.textPrimary,
              side: const BorderSide(color: AppThemeTokens.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/branch_inventory_item_entity.dart';

class BranchInventoryItemCard extends StatelessWidget {
  final BranchInventoryItemEntity item;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  BranchInventoryItemCard({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = item.stockQuantity <= 50;
    final stockColor = isLowStock
        ? AppThemeTokens.error
        : Theme.of(context).colorScheme.primary;

    final categoryText =
        item.subCategoryName == null || item.subCategoryName!.trim().isEmpty
            ? item.categoryName
            : '${item.categoryName} • ${item.subCategoryName}';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            categoryText,
            style: TextStyle(
              fontSize: 14,
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
                  context.l10n.stockWithQuantity(item.stockQuantity),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: stockColor,
                  ),
                ),
              ),
              Spacer(),
              OutlinedButton.icon(
                onPressed: onUpdate,
                icon: Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  context.l10n.updateButton,
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/branch_entity.dart';

class BranchCard extends StatelessWidget {
  final BranchEntity branch;
  final int totalProducts;
  final int totalStock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewInventory;

  BranchCard({
    super.key,
    required this.branch,
    required this.totalProducts,
    required this.totalStock,
    required this.onEdit,
    required this.onDelete,
    required this.onViewInventory,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BranchIcon(primaryColor: primaryColor),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      branch.locationLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      branch.address,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      branch.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  context.l10n.editButton,
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
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: context.l10n.totalProductsLabel,
                  value: totalProducts.toString(),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _StatBox(
                  label: context.l10n.totalStockLabel,
                  value: _formatNumber(totalStock),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _StatusRow(
            status: branch.status,
            onDelete: onDelete,
          ),
          SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onViewInventory,
            icon: Icon(Icons.inventory_2_outlined, size: 20),
            label: Text(
              context.l10n.viewInventoryButton,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeTokens.textPrimary,
              side: BorderSide(color: AppThemeTokens.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
              ),
              padding: EdgeInsets.symmetric(vertical: 13),
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

class _BranchIcon extends StatelessWidget {
  final Color primaryColor;

  _BranchIcon({
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.location_on_outlined,
        color: primaryColor,
        size: 30,
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final BranchStatus status;
  final VoidCallback onDelete;

  _StatusRow({
    required this.status,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == BranchStatus.active;
    final statusColor = isActive
        ? Theme.of(context).colorScheme.primary
        : AppThemeTokens.error;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isActive ? context.l10n.activeStatus : context.l10n.inactiveStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: statusColor,
            ),
          ),
        ),
        Spacer(),
        TextButton.icon(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, size: 18),
          label: Text(
            context.l10n.delete,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppThemeTokens.error,
          ),
        ),
      ],
    );
  }
}

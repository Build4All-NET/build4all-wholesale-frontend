import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/branch_entity.dart';

class BranchCard extends StatelessWidget {
  final BranchEntity branch;
  final int totalProducts;
  final int totalStock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewInventory;

  const BranchCard({
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
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BranchIcon(primaryColor: primaryColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.city,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      branch.address,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w800),
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total Products',
                  value: totalProducts.toString(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatBox(
                  label: 'Total Stock',
                  value: _formatNumber(totalStock),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatusRow(
            status: branch.status,
            onDelete: onDelete,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onViewInventory,
            icon: const Icon(Icons.inventory_2_outlined, size: 20),
            label: const Text(
              'View Inventory',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeTokens.textPrimary,
              side: const BorderSide(color: AppThemeTokens.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
              minimumSize: const Size(double.infinity, 48),
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

  const _BranchIcon({
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

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
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

  const _StatusRow({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: statusColor,
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text(
            'Delete',
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
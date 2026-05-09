import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelRowCard extends StatelessWidget {
  final SupplierExcelProductRowEntity row;

  const SupplierExcelRowCard({
    super.key,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final borderColor = row.isValid ? AppThemeTokens.border : AppThemeTokens.error.withOpacity(0.45);
    final badgeColor = row.isValid ? primary : AppThemeTokens.error;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Row ${row.rowNumber}',
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.productName.isEmpty ? 'Unnamed product' : row.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                row.isValid ? Icons.check_circle : Icons.error,
                color: badgeColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Category', value: row.categoryName),
              _InfoChip(label: 'SubCategory', value: row.subCategoryName.isEmpty ? '-' : row.subCategoryName),
              _InfoChip(label: 'Price', value: row.priceText),
              _InfoChip(label: 'MOQ', value: row.moqText),
              _InfoChip(label: 'Status', value: row.statusText),
            ],
          ),
          if (row.errors.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...row.errors.map(
              (error) => _MessageLine(
                message: error,
                icon: Icons.error_outline,
                color: AppThemeTokens.error,
              ),
            ),
          ],
          if (row.warnings.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...row.warnings.map(
              (warning) => _MessageLine(
                message: warning,
                icon: Icons.info_outline,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        '$label: ${value.isEmpty ? '-' : value}',
        style: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MessageLine extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _MessageLine({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

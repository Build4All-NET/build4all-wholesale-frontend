import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';

class SupplierExcelRowCard extends StatelessWidget {
  final SupplierExcelProductRowEntity row;
  final VoidCallback onEdit;

  SupplierExcelRowCard({
    super.key,
    required this.row,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final borderColor = row.isValid
        ? primary.withOpacity(0.35)
        : AppThemeTokens.error.withOpacity(0.45);
    final badgeColor = row.isValid ? primary : AppThemeTokens.error;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.rowNumberLabel(row.rowNumber),
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.productName.isEmpty ? context.l10n.unnamedProduct : row.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: context.l10n.categoryLabel, value: row.categoryName),
              _InfoChip(
                label: context.l10n.subCategoryLabel,
                value: row.subCategoryName.isEmpty ? '-' : row.subCategoryName,
              ),
              _InfoChip(label: context.l10n.priceLabel, value: row.priceText),
              _InfoChip(label: context.l10n.moqLabel, value: row.moqText),
              _InfoChip(label: context.l10n.statusLabel, value: row.statusText),
            ],
          ),
          if (row.errors.isNotEmpty) ...[
            SizedBox(height: 12),
            ...row.errors.map(
              (error) => _MessageLine(
                message: error,
                icon: Icons.error_outline,
                color: AppThemeTokens.error,
              ),
            ),
          ],
          if (row.warnings.isNotEmpty) ...[
            SizedBox(height: 10),
            ...row.warnings.map(
              (warning) => _MessageLine(
                message: warning,
                icon: Icons.info_outline,
                color: Colors.orange,
              ),
            ),
          ],
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 18),
              label: Text(context.l10n.editRowButton),
              style: TextButton.styleFrom(
                foregroundColor: primary,
                textStyle: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        '$label: ${value.isEmpty ? '-' : value}',
        style: TextStyle(
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

  _MessageLine({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
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

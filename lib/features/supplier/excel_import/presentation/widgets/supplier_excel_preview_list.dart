import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';
import 'supplier_excel_row_card.dart';

class SupplierExcelPreviewList extends StatelessWidget {
  final List<SupplierExcelProductRowEntity> rows;
  final void Function(SupplierExcelProductRowEntity row) onEditRow;

  SupplierExcelPreviewList({
    super.key,
    required this.rows,
    required this.onEditRow,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 42,
              color: AppThemeTokens.textSecondary,
            ),
            SizedBox(height: 10),
            Text(
              context.l10n.noRowsToPreview,
              style: TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              context.l10n.selectExcelToPreview,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.previewRowsTitle,
          style: TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 6),
        Text(
          context.l10n.previewRowsHelp,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        SizedBox(height: 12),
        ...rows.map(
          (row) => SupplierExcelRowCard(
            row: row,
            onEdit: () => onEditRow(row),
          ),
        ),
      ],
    );
  }
}

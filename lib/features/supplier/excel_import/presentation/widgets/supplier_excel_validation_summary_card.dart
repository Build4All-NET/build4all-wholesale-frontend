import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelValidationSummaryCard extends StatelessWidget {
  final int totalRows;
  final int validRows;
  final int errorRows;
  final int warningRows;

  const SupplierExcelValidationSummaryCard({
    super.key,
    required this.totalRows,
    required this.validRows,
    required this.errorRows,
    required this.warningRows,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    final tiles = [
      _SummaryTileData(
        label: l.rows,
        value: totalRows.toString(),
        icon: Icons.table_rows_outlined,
      ),
      _SummaryTileData(
        label: l.valid,
        value: validRows.toString(),
        icon: Icons.check_circle_outline,
      ),
      _SummaryTileData(
        label: l.errors,
        value: errorRows.toString(),
        icon: Icons.error_outline,
        isError: true,
      ),
      _SummaryTileData(
        label: l.warnings,
        value: warningRows.toString(),
        icon: Icons.info_outline,
        isWarning: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.35,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        final color = tile.isError
            ? AppThemeTokens.error
            : tile.isWarning
                ? Colors.orange
                : Theme.of(context).colorScheme.primary;

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
            border: Border.all(color: AppThemeTokens.border),
          ),
          child: Row(
            children: [
              Icon(tile.icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tile.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tile.value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryTileData {
  final String label;
  final String value;
  final IconData icon;
  final bool isError;
  final bool isWarning;

  const _SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
    this.isError = false,
    this.isWarning = false,
  });
}

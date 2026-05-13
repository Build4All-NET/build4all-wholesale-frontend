import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class SupplierExcelValidationSummaryCard extends StatelessWidget {
  final int totalRows;
  final int validRows;
  final int errorRows;
  final int warningRows;

  SupplierExcelValidationSummaryCard({
    super.key,
    required this.totalRows,
    required this.validRows,
    required this.errorRows,
    required this.warningRows,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _SummaryTileData(
        label: context.l10n.rowsLabel,
        value: totalRows.toString(),
        icon: Icons.table_rows_outlined,
      ),
      _SummaryTileData(
        label: context.l10n.validLabel,
        value: validRows.toString(),
        icon: Icons.check_circle_outline,
      ),
      _SummaryTileData(
        label: context.l10n.errorsLabel,
        value: errorRows.toString(),
        icon: Icons.error_outline,
        isError: true,
      ),
      if (warningRows > 0)
        _SummaryTileData(
          label: context.l10n.warningsLabel,
          value: warningRows.toString(),
          icon: Icons.info_outline,
          isWarning: true,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return _SummaryTile(
          label: tile.label,
          value: tile.value,
          icon: tile.icon,
          isError: tile.isError,
          isWarning: tile.isWarning,
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

  _SummaryTileData({
    required this.label,
    required this.value,
    required this.icon,
    this.isError = false,
    this.isWarning = false,
  });
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isError;
  final bool isWarning;

  _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isError = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? AppThemeTokens.error
        : isWarning
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

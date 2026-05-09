import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

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
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Rows',
            value: totalRows.toString(),
            icon: Icons.table_rows_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Valid',
            value: validRows.toString(),
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Errors',
            value: errorRows.toString(),
            icon: Icons.error_outline,
            isError: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Warnings',
            value: warningRows.toString(),
            icon: Icons.info_outline,
            isWarning: true,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isError;
  final bool isWarning;

  const _SummaryTile({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
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

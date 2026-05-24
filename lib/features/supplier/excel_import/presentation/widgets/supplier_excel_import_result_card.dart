import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_excel_import_result_entity.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelImportResultCard extends StatelessWidget {
  final SupplierExcelImportResultEntity result;

  const SupplierExcelImportResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;
    final color = result.hasFailures ? Colors.orange.shade700 : primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.hasFailures
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.hasFailures ? l.importPartial : l.importSuccess,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: l.rows,
                value: result.totalRows.toString(),
                color: primary,
              ),
              _MetricChip(
                label: l.imported,
                value: result.importedCount.toString(),
                color: primary,
              ),
              _MetricChip(
                label: l.failed,
                value: result.failedCount.toString(),
                color: AppThemeTokens.error,
              ),
            ],
          ),
          if (result.failedMessages.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.details,
              style: TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...result.failedMessages.take(8).map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $message',
                      style: TextStyle(
                        color: AppThemeTokens.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
          ],
          if (result.messages.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...result.messages.take(10).map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '• $message',
                      style: TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      backgroundColor: color.withOpacity(0.10),
      side: BorderSide(color: color.withOpacity(0.25)),
    );
  }
}

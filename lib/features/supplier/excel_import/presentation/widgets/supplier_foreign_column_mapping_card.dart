import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_foreign_field.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';
import '../utils/supplier_excel_import_i18n.dart';

/// What each column of the supplier's own file was taken to be, with every
/// guess changeable.
///
/// The guesses are a proposal, not a decision: a shaky one is marked so it reads
/// as a question, and where the assistant and the values disagreed both readings
/// are shown rather than one of them being picked quietly.
class SupplierForeignColumnMappingCard extends StatelessWidget {
  final SupplierForeignSheetMapping sheet;
  final void Function(int columnIndex, SupplierForeignField field) onChanged;

  const SupplierForeignColumnMappingCard({
    super.key,
    required this.sheet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.foreignColumnsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.foreignColumnsSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                sheet.aiUsed ? Icons.auto_awesome : Icons.functions_rounded,
                size: 14,
                color: AppThemeTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sheet.aiUsed ? l.foreignAiUsed : l.foreignAiNotUsed,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sheet.columns.map(
            (column) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ColumnRow(
                column: column,
                onChanged: (field) => onChanged(column.columnIndex, field),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnRow extends StatelessWidget {
  final SupplierForeignColumnGuess column;
  final ValueChanged<SupplierForeignField> onChanged;

  const _ColumnRow({required this.column, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    final header = column.header.trim().isEmpty
        ? l.foreignNoHeading
        : column.header.trim();

    final flagged = column.needsAttention && !column.isIgnored;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: flagged
            ? AppThemeTokens.error.withOpacity(0.04)
            : AppThemeTokens.inputFill,
        border: Border.all(
          color: flagged ? AppThemeTokens.error.withOpacity(0.4)
              : AppThemeTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<SupplierForeignField>(
            value: column.field,
            isDense: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: AppThemeTokens.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppThemeTokens.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppThemeTokens.border),
              ),
            ),
            items: SupplierForeignField.values
                .map(
                  (field) => DropdownMenuItem(
                    value: field,
                    child: Text(
                      l.foreignField(field.wireName),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (field) {
              if (field != null) onChanged(field);
            },
          ),
          const SizedBox(height: 4),
          Text(
            _reasonText(l),
            style: TextStyle(
              fontSize: 11,
              color: flagged
                  ? AppThemeTokens.error
                  : AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _reasonText(SupplierExcelImportI18n l) {
    switch (column.reason) {
      case SupplierForeignGuessReason.agreed:
        return l.foreignReasonAgreed;
      case SupplierForeignGuessReason.fromValues:
        return l.foreignReasonFromValues;
      case SupplierForeignGuessReason.fromHeading:
        return l.foreignReasonFromHeading;
      case SupplierForeignGuessReason.fromAssistant:
        return l.foreignReasonFromAssistant;
      case SupplierForeignGuessReason.disputed:
        return l.foreignReasonDisputed(
          l.foreignField(
            (column.disputedWith ?? SupplierForeignField.ignore).wireName,
          ),
        );
      case SupplierForeignGuessReason.noMatch:
        return l.foreignReasonNoMatch;
    }
  }
}

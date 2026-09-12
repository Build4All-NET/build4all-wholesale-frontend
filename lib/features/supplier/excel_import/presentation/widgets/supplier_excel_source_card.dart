import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../bloc/supplier_excel_import_state.dart';
import '../utils/supplier_excel_import_i18n.dart';

/// Where the supplier's products are coming from -- a file already kept, or
/// a shelf that has never been written down. Asked once, up front, so a
/// supplier with a file never reads the steps of the way in they didn't
/// choose.
class SupplierExcelSourceCard extends StatelessWidget {
  final SupplierExcelSource? source;
  final ValueChanged<SupplierExcelSource> onChanged;

  const SupplierExcelSourceCard({
    super.key,
    required this.source,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.sourceQuestion,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _SourceOption(
          selected: source == SupplierExcelSource.file,
          title: l.sourceFileTitle,
          subtitle: l.sourceFileSubtitle,
          onTap: () => onChanged(SupplierExcelSource.file),
        ),
        const SizedBox(height: 10),
        _SourceOption(
          selected: source == SupplierExcelSource.photos,
          title: l.sourcePhotosTitle,
          subtitle: l.sourcePhotosSubtitle,
          onTap: () => onChanged(SupplierExcelSource.photos),
        ),
      ],
    );
  }
}

class _SourceOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(
            color: selected ? primary : AppThemeTokens.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primary : AppThemeTokens.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

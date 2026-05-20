import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelTemplateCard extends StatelessWidget {
  final bool isDownloading;
  final String? savedPath;
  final VoidCallback onDownload;

  const SupplierExcelTemplateCard({
    super.key,
    required this.isDownloading,
    required this.savedPath,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;
    final hasPath = savedPath != null && savedPath!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.file_download_outlined, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.templateTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.templateSubtitle,
                      style: TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isDownloading ? null : onDownload,
              icon: isDownloading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                isDownloading ? l.downloadingTemplate : l.downloadTemplate,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary.withOpacity(0.40)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (hasPath) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeTokens.inputFill,
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                border: Border.all(color: AppThemeTokens.border),
              ),
              child: Text(
                '${l.templateSaved}\n$savedPath',
                style: TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

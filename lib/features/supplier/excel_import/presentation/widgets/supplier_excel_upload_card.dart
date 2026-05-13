import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class SupplierExcelUploadCard extends StatelessWidget {
  final String? fileName;
  final bool isLoading;
  final VoidCallback onPickFile;
  final VoidCallback onClear;

  SupplierExcelUploadCard({
    super.key,
    required this.fileName,
    required this.isLoading,
    required this.onPickFile,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.uploadExcelFile,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            fileName == null ? context.l10n.acceptedExcelFormat : fileName!,
            style: TextStyle(
              color: fileName == null ? AppThemeTokens.textSecondary : primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onPickFile,
                  icon: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.attach_file),
                  label: Text(isLoading ? context.l10n.readingFile : context.l10n.selectExcel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (fileName != null) ...[
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onClear,
                  icon: Icon(Icons.refresh),
                  label: Text(context.l10n.clearButton),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

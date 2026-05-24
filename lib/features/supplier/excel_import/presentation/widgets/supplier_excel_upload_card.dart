import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelUploadCard extends StatelessWidget {
  final String? fileName;
  final bool isLoading;
  final VoidCallback onPickFile;
  final VoidCallback onClear;

  const SupplierExcelUploadCard({
    super.key,
    required this.fileName,
    required this.isLoading,
    required this.onPickFile,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;
    final hasFile = fileName != null && fileName!.trim().isNotEmpty;

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
          Text(
            l.selectedFile,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppThemeTokens.inputFill,
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.description_outlined : Icons.insert_drive_file_outlined,
                  color: hasFile ? primary : AppThemeTokens.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasFile ? fileName! : l.noFile,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasFile
                          ? AppThemeTokens.textPrimary
                          : AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onPickFile,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: Text(
                    hasFile ? l.replaceFile : l.pickFile,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              if (hasFile) ...[
                const SizedBox(width: 10),
                IconButton.outlined(
                  tooltip: l.clear,
                  onPressed: isLoading ? null : onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

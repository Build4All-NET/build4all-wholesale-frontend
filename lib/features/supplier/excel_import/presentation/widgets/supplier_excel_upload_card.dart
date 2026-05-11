import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

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
    final primary = Theme.of(context).colorScheme.primary;

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
          const Text(
            'Upload Excel File',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fileName == null ? 'Accepted format: .xlsx' : fileName!,
            style: TextStyle(
              color: fileName == null ? AppThemeTokens.textSecondary : primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onPickFile,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file),
                  label: Text(isLoading ? 'Reading file...' : 'Select Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (fileName != null) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onClear,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
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

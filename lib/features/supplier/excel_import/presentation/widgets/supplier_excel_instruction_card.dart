import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class SupplierExcelInstructionCard extends StatelessWidget {
  const SupplierExcelInstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Import product information only',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'This import creates supplier products in bulk. Branch stock is not imported here because stock belongs to Branch Inventory.',
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create categories and subcategories first, then upload the Excel file so rows can be matched safely.',
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

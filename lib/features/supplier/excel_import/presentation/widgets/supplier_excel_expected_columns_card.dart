import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/services/supplier_excel_reader_service.dart';

class SupplierExcelExpectedColumnsCard extends StatelessWidget {
  SupplierExcelExpectedColumnsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.expectedColumnsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SupplierExcelReaderService.expectedHeaders.map((header) {
              return Chip(
                label: Text(
                  header,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                backgroundColor: AppThemeTokens.inputFill,
                side: BorderSide(color: AppThemeTokens.border),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

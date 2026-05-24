import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../data/services/supplier_excel_reader_service.dart';
import '../../domain/entities/supplier_excel_section.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelExpectedColumnsCard extends StatelessWidget {
  const SupplierExcelExpectedColumnsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.auto_awesome_outlined, color: primary),
          title: Text(
            l.templateStructureTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          subtitle: Text(
            l.templateStructureSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            ...SupplierExcelSectionX.importSections.map((section) {
              final headers = SupplierExcelReaderService.headersFor(section);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CoreSectionLine(
                  title: l.sectionTitle(section.name),
                  sheetName: section.sheetName,
                  headers: headers,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CoreSectionLine extends StatelessWidget {
  final String title;
  final String sheetName;
  final List<String> headers;

  const _CoreSectionLine({
    required this.title,
    required this.sheetName,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.inputFill,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title  •  $sheetName',
            style: TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${l.mainColumns}: ${headers.map((h) => l.headerLabel(SupplierExcelReaderService.normalizeHeaderForUi(h))).join(', ')}',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

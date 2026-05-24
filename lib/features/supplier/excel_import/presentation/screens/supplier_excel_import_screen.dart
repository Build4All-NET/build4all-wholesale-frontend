import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/supplier_excel_section.dart';
import '../bloc/supplier_excel_import_bloc.dart';
import '../bloc/supplier_excel_import_event.dart';
import '../bloc/supplier_excel_import_state.dart';
import '../utils/supplier_excel_import_i18n.dart';
import '../widgets/supplier_excel_expected_columns_card.dart';
import '../widgets/supplier_excel_import_result_card.dart';
import '../widgets/supplier_excel_instruction_card.dart';
import '../widgets/supplier_excel_template_card.dart';
import '../widgets/supplier_excel_preview_list.dart';
import '../widgets/supplier_excel_upload_card.dart';
import '../widgets/supplier_excel_validation_summary_card.dart';

class SupplierExcelImportScreen extends StatelessWidget {
  const SupplierExcelImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierExcelImportBloc>(),
      child: const _SupplierExcelImportView(),
    );
  }
}

class _SupplierExcelImportView extends StatelessWidget {
  const _SupplierExcelImportView();

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<SupplierExcelImportBloc, SupplierExcelImportState>(
      listener: (context, state) {
        if (state.error != null && state.error!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppThemeTokens.error,
            ),
          );
        }

        if (state.successMessage != null) {
          final message = state.successMessage == 'supplierExcelTemplateDownloaded'
              ? l.templateDownloaded
              : state.successMessage == 'supplierExcelImportPartial'
                  ? l.importPartial
                  : l.importSuccess;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: primary,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          drawer: const SupplierAppDrawer(),
          appBar: AppBar(
            title: Text(l.title),
            backgroundColor: AppThemeTokens.surface,
            foregroundColor: AppThemeTokens.textPrimary,
            elevation: 0,
          ),
          bottomNavigationBar: _ImportBottomBar(state: state),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppThemeTokens.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SupplierExcelInstructionCard(),
                  const SizedBox(height: 16),
                  SupplierExcelTemplateCard(
                    isDownloading: state.isDownloadingTemplate,
                    savedPath: state.templateSavePath,
                    onDownload: () {
                      context
                          .read<SupplierExcelImportBloc>()
                          .add(const SupplierExcelDownloadTemplateRequested());
                    },
                  ),
                  const SizedBox(height: 16),
                  SupplierExcelUploadCard(
                    fileName: state.fileName,
                    isLoading: state.isPickingOrParsing,
                    onPickFile: () {
                      context
                          .read<SupplierExcelImportBloc>()
                          .add(const SupplierExcelPickFileRequested());
                    },
                    onClear: () {
                      context
                          .read<SupplierExcelImportBloc>()
                          .add(const SupplierExcelClearRequested());
                    },
                  ),
                  const SizedBox(height: 16),
                  const SupplierExcelExpectedColumnsCard(),
                  const SizedBox(height: 16),
                  SupplierExcelValidationSummaryCard(
                    totalRows: state.totalRows,
                    validRows: state.validRowsCount,
                    errorRows: state.errorRowsCount,
                    warningRows: state.warningRowsCount,
                  ),
                  const SizedBox(height: 16),
                  if (state.parsedFile != null)
                    SupplierExcelPreviewList(parsedFile: state.parsedFile!)
                  else
                    _EmptyPreviewCard(message: l.noRows),
                  const SizedBox(height: 16),
                  if (state.importResult != null)
                    SupplierExcelImportResultCard(result: state.importResult!),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImportBottomBar extends StatelessWidget {
  final SupplierExcelImportState state;

  const _ImportBottomBar({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border(top: BorderSide(color: AppThemeTokens.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.isImporting
                    ? null
                    : () {
                        context
                            .read<SupplierExcelImportBloc>()
                            .add(const SupplierExcelClearRequested());
                      },
                icon: const Icon(Icons.clear_rounded),
                label: Text(
                  l.clear,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.textPrimary,
                  side: BorderSide(color: AppThemeTokens.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: state.canImport
                    ? () {
                        context
                            .read<SupplierExcelImportBloc>()
                            .add(const SupplierExcelImportRequested());
                      }
                    : null,
                icon: state.isImporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded),
                label: Text(
                  state.isImporting ? l.importing : l.import,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppThemeTokens.textSecondary.withOpacity(0.25),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPreviewCard extends StatelessWidget {
  final String message;

  const _EmptyPreviewCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.table_chart_outlined,
            color: AppThemeTokens.textSecondary,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.workbookStructureHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: SupplierExcelSectionX.importSections
                .map((section) => Chip(label: Text(section.sheetName)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

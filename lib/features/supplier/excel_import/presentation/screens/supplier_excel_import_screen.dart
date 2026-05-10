import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/supplier_excel_product_row_entity.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../bloc/supplier_excel_import_bloc.dart';
import '../bloc/supplier_excel_import_event.dart';
import '../bloc/supplier_excel_import_state.dart';
import '../widgets/supplier_excel_edit_row_dialog.dart';
import '../widgets/supplier_excel_expected_columns_card.dart';
import '../widgets/supplier_excel_instruction_card.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<SupplierExcelImportBloc, SupplierExcelImportState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppThemeTokens.error,
            ),
          );
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
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
            title: const Text('Import Excel'),
            backgroundColor: AppThemeTokens.surface,
            foregroundColor: AppThemeTokens.textPrimary,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Manage Categories',
                onPressed: () => context.push('/supplier-catalog'),
                icon: const Icon(Icons.category_outlined),
              ),
              const SizedBox(width: 6),
            ],
          ),
          bottomNavigationBar: _ImportBottomBar(state: state),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SupplierExcelInstructionCard(),
                  const SizedBox(height: 16),
                  SupplierExcelUploadCard(
                    fileName: state.fileName,
                    isLoading: state.isPickingOrParsing,
                    onPickFile: () {
                      context.read<SupplierExcelImportBloc>().add(
                            const SupplierExcelPickFileRequested(),
                          );
                    },
                    onClear: () {
                      context.read<SupplierExcelImportBloc>().add(
                            const SupplierExcelClearRequested(),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  const SupplierExcelExpectedColumnsCard(),
                  const SizedBox(height: 16),
                  if (state.hasRows) ...[
                    SupplierExcelValidationSummaryCard(
                      totalRows: state.totalRows,
                      validRows: state.validRowsCount,
                      errorRows: state.errorRowsCount,
                      warningRows: state.warningRowsCount,
                    ),
                    const SizedBox(height: 16),
                    _ValidationHelpCard(state: state),
                    const SizedBox(height: 16),
                  ],
                  if (state.importResult != null) ...[
                    _ImportResultCard(state: state),
                    const SizedBox(height: 16),
                  ],
                  SupplierExcelPreviewList(
                    rows: state.rows,
                    onEditRow: (row) => _openEditRowDialog(
                      context: context,
                      state: state,
                      row: row,
                    ),
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditRowDialog({
    required BuildContext context,
    required SupplierExcelImportState state,
    required SupplierExcelProductRowEntity row,
  }) async {
    final updatedRow = await showDialog<SupplierExcelProductRowEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SupplierExcelEditRowDialog(
        row: row,
        categories: state.categories,
        subCategoriesByCategoryId: state.subCategoriesByCategoryId,
      ),
    );

    if (updatedRow == null || !context.mounted) return;

    context.read<SupplierExcelImportBloc>().add(
          SupplierExcelRowUpdated(row: updatedRow),
        );
  }
}

class _ValidationHelpCard extends StatelessWidget {
  final SupplierExcelImportState state;

  const _ValidationHelpCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final title = state.hasErrors
        ? 'Some rows need attention'
        : 'All rows are ready to import';

    final message = state.hasErrors
        ? 'You can edit invalid rows inside this screen, fix the Excel file and upload it again, or manage missing categories first.'
        : 'Review the rows below, then import the valid products. Branch stock is still managed from Branch Inventory.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.hasErrors
            ? const Color(0xFFFFF7ED)
            : primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: state.hasErrors
              ? const Color(0xFFFED7AA)
              : primary.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.hasErrors
                    ? Icons.info_outline
                    : Icons.check_circle_outline,
                color: state.hasErrors ? const Color(0xFFF97316) : primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: state.hasErrors
                        ? const Color(0xFF9A3412)
                        : AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          if (state.hasCatalogErrors) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/supplier-catalog'),
              icon: const Icon(Icons.category_outlined),
              label: const Text('Manage Categories'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImportResultCard extends StatelessWidget {
  final SupplierExcelImportState state;

  const _ImportResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.importResult!;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.done_all_outlined, color: primary),
              const SizedBox(width: 8),
              const Text(
                'Import Result',
                style: TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Imported: ${result.importedCount} / ${result.totalRows}',
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (result.failedMessages.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...result.failedMessages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppThemeTokens.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImportBottomBar extends StatelessWidget {
  final SupplierExcelImportState state;

  const _ImportBottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border(top: BorderSide(color: AppThemeTokens.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.isImporting
                    ? null
                    : () {
                        context.read<SupplierExcelImportBloc>().add(
                              const SupplierExcelClearRequested(),
                            );
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: state.canImport
                    ? () {
                        context.read<SupplierExcelImportBloc>().add(
                              const SupplierExcelImportRequested(),
                            );
                      }
                    : null,
                icon: state.isImporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  state.isImporting
                      ? 'Importing...'
                      : 'Import ${state.validRowsCount} Products',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppThemeTokens.border,
                  disabledForegroundColor: AppThemeTokens.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

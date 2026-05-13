import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

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
  SupplierExcelImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierExcelImportBloc>(),
      child: _SupplierExcelImportView(),
    );
  }
}

class _SupplierExcelImportView extends StatelessWidget {
  _SupplierExcelImportView();

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
          drawer: SupplierAppDrawer(),
          appBar: AppBar(
            title: Text(context.l10n.importExcelTitle),
            backgroundColor: AppThemeTokens.surface,
            foregroundColor: AppThemeTokens.textPrimary,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: context.l10n.manageCategoriesTooltip,
                onPressed: () => context.push('/supplier-catalog'),
                icon: Icon(Icons.category_outlined),
              ),
              SizedBox(width: 6),
            ],
          ),
          bottomNavigationBar: _ImportBottomBar(state: state),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                AppThemeTokens.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SupplierExcelInstructionCard(),
                  SizedBox(height: 16),
                  SupplierExcelUploadCard(
                    fileName: state.fileName,
                    isLoading: state.isPickingOrParsing,
                    onPickFile: () {
                      context.read<SupplierExcelImportBloc>().add(
                            SupplierExcelPickFileRequested(),
                          );
                    },
                    onClear: () {
                      context.read<SupplierExcelImportBloc>().add(
                            SupplierExcelClearRequested(),
                          );
                    },
                  ),
                  SizedBox(height: 16),
                  SupplierExcelExpectedColumnsCard(),
                  SizedBox(height: 16),
                  if (state.hasRows) ...[
                    SupplierExcelValidationSummaryCard(
                      totalRows: state.totalRows,
                      validRows: state.validRowsCount,
                      errorRows: state.errorRowsCount,
                      warningRows: state.warningRowsCount,
                    ),
                    SizedBox(height: 16),
                    _ValidationHelpCard(state: state),
                    SizedBox(height: 16),
                  ],
                  if (state.importResult != null) ...[
                    _ImportResultCard(state: state),
                    SizedBox(height: 16),
                  ],
                  SupplierExcelPreviewList(
                    rows: state.rows,
                    onEditRow: (row) => _openEditRowDialog(
                      context: context,
                      state: state,
                      row: row,
                    ),
                  ),
                  SizedBox(height: 96),
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

  _ValidationHelpCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final title = state.hasErrors
        ? context.l10n.someRowsNeedAttention
        : context.l10n.allRowsReady;

    final message = state.hasErrors
        ? context.l10n.excelAttentionHelp
        : 'Review the rows below, then import the valid products. Branch stock is still managed from Branch Inventory.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.hasErrors
            ? Color(0xFFFFF7ED)
            : primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: state.hasErrors
              ? Color(0xFFFED7AA)
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
                color: state.hasErrors ? Color(0xFFF97316) : primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: state.hasErrors
                        ? Color(0xFF9A3412)
                        : AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          if (state.hasCatalogErrors) ...[
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/supplier-catalog'),
              icon: Icon(Icons.category_outlined),
              label: Text(context.l10n.manageCategoriesButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                padding: EdgeInsets.symmetric(
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

  _ImportResultCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.importResult!;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 8),
              Text(
                context.l10n.importResultTitle,
                style: TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            context.l10n.importedRowsSummary(result.importedCount, result.totalRows),
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (result.failedMessages.isNotEmpty) ...[
            SizedBox(height: 10),
            ...result.failedMessages.map(
              (message) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  message,
                  style: TextStyle(
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

  _ImportBottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border(top: BorderSide(color: AppThemeTokens.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: Offset(0, -6),
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
                              SupplierExcelClearRequested(),
                            );
                      },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.l10n.resetButton,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: state.canImport
                    ? () {
                        context.read<SupplierExcelImportBloc>().add(
                              SupplierExcelImportRequested(),
                            );
                      }
                    : null,
                icon: state.isImporting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.cloud_upload_outlined),
                label: Text(
                  state.isImporting
                      ? context.l10n.importingLabel
                      : context.l10n.importProductsButton(state.validRowsCount),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppThemeTokens.border,
                  disabledForegroundColor: AppThemeTokens.textSecondary,
                  padding: EdgeInsets.symmetric(
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

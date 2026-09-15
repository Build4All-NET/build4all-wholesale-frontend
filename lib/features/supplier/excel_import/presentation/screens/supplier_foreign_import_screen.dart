import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../../gallery/presentation/widgets/supplier_gallery_picker_sheet.dart';
import '../../domain/entities/supplier_foreign_preview.dart';
import '../../domain/entities/supplier_foreign_sheet_mapping.dart';
import '../cubit/supplier_foreign_import_cubit.dart';
import '../utils/supplier_excel_import_i18n.dart';
import '../widgets/supplier_excel_import_result_card.dart';
import '../widgets/supplier_foreign_column_mapping_card.dart';
import '../widgets/supplier_foreign_review_list.dart';

/// Importing a catalogue from a file the supplier's own system wrote.
///
/// Three steps, in the order they meet them: choose the file, agree to what each
/// column holds, and look at the products before any of them exist.
class SupplierForeignImportScreen extends StatelessWidget {
  const SupplierForeignImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierForeignImportCubit>(),
      child: const _SupplierForeignImportView(),
    );
  }
}

class _SupplierForeignImportView extends StatelessWidget {
  const _SupplierForeignImportView();

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.surface,
        elevation: 0,
        title: Text(
          l.foreignTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppThemeTokens.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<SupplierForeignImportCubit, SupplierForeignImportState>(
        listenWhen: (prev, next) => next.error != null && prev.error != next.error,
        listener: (context, state) {
          AppToast.error(context, _errorText(l, state.error!));
          context.read<SupplierForeignImportCubit>().clearError();
        },
        builder: (context, state) {
          final cubit = context.read<SupplierForeignImportCubit>();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  if (state.step == SupplierForeignStep.pickFile)
                    _PickFileCard(
                      busy: state.busy,
                      onPick: cubit.chooseFile,
                    ),

                  if (state.step == SupplierForeignStep.confirmColumns &&
                      state.sheet != null) ...[
                    if (state.sheets.length > 1) ...[
                      _SheetPicker(
                        sheets: state.sheets,
                        selected: state.selectedSheet,
                        onSelected: cubit.selectSheet,
                      ),
                      const SizedBox(height: 16),
                    ],
                    SupplierForeignColumnMappingCard(
                      sheet: state.sheet!,
                      onChanged: cubit.setColumnField,
                    ),
                    const SizedBox(height: 16),
                    _TextFieldCard(
                      title: l.foreignCategoryTitle,
                      hint: l.foreignCategoryHint,
                      value: state.categoryName,
                      onChanged: cubit.setCategoryName,
                    ),
                    if (state.sheet!.hasStock) ...[
                      const SizedBox(height: 16),
                      _BranchPickerCard(
                        branches: state.branches,
                        selected: state.branchName,
                        loading: state.loadingBranches,
                        noBranchesAtAll: state.hasNoBranchesAtAll,
                        onChanged: cubit.setBranchName,
                      ),
                    ],
                  ],

                  if (state.step == SupplierForeignStep.review &&
                      state.preview != null)
                    SupplierForeignReviewList(
                      preview: state.preview!,
                      onPriceChanged: (row, price) =>
                          cubit.editRow(row, price: price),
                      onDescriptionChanged: (row, description) =>
                          cubit.editRow(row, description: description),
                      onPickImage: (product) => _pickImage(context, product),
                      onWriteDescriptions: cubit.writeMissingDescriptions,
                      assistantAvailable: state.assistantAvailable,
                      writingDescriptions: state.writingDescriptions,
                      needingDescription: state.needingDescription.length,
                    ),

                  if (state.step == SupplierForeignStep.done &&
                      state.result != null)
                    SupplierExcelImportResultCard(result: state.result!),
                ],
              ),

              if (state.busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x11000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const _ForeignBottomBar(),
    );
  }

  /// Picks a picture for one row out of the supplier's own gallery.
  ///
  /// The same sheet the product and banner screens use, so a picture they
  /// uploaded once is reachable everywhere they need one.
  static Future<void> _pickImage(
    BuildContext context,
    SupplierForeignProductPreview product,
  ) async {
    final cubit = context.read<SupplierForeignImportCubit>();
    final url = await showSupplierGalleryPickerSheet(context);

    if (url == null || url.trim().isEmpty) return;
    await cubit.editRow(product.row, imageUrl: url.trim());
  }

  /// The server sends codes for the things it refuses, so they read here in the
  /// supplier's own language rather than in the server's.
  static String _errorText(SupplierExcelImportI18n l, String code) {
    switch (code) {
      case 'NO_SHEETS':
        return l.foreignNoSheets;
      case 'NEEDS_NAME':
        return l.foreignNeedsName;
      case 'NOTHING_TO_IMPORT':
        return l.foreignNothingToImport;
      default:
        return code;
    }
  }
}

class _ForeignBottomBar extends StatelessWidget {
  const _ForeignBottomBar();

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return BlocBuilder<SupplierForeignImportCubit, SupplierForeignImportState>(
      builder: (context, state) {
        final cubit = context.read<SupplierForeignImportCubit>();

        if (state.step == SupplierForeignStep.pickFile ||
            state.step == SupplierForeignStep.done) {
          return const SizedBox.shrink();
        }

        final isReview = state.step == SupplierForeignStep.review;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (isReview) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.busy ? null : cubit.backToColumns,
                      child: Text(l.foreignBackToColumns),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: state.busy
                        ? null
                        : (isReview
                            ? cubit.runImport
                            : (state.canContinue ? cubit.showPreview : null)),
                    child: Text(
                      isReview
                          ? (state.busy ? l.foreignImporting : l.foreignImport)
                          : l.foreignContinue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PickFileCard extends StatelessWidget {
  final bool busy;
  final VoidCallback onPick;

  const _PickFileCard({required this.busy, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.sourceForeignTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.sourceForeignSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : onPick,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(busy ? l.foreignReadingFile : l.foreignPickFile),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetPicker extends StatelessWidget {
  final List<SupplierForeignSheetMapping> sheets;
  final int selected;
  final ValueChanged<int> onSelected;

  const _SheetPicker({
    required this.sheets,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.foreignSheetPickerTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(sheets.length, (i) {
              final sheet = sheets[i];
              final isSelected = i == selected;

              return ChoiceChip(
                selected: isSelected,
                onSelected: (_) => onSelected(i),
                label: Text(
                  '${sheet.sheetName} · ${l.foreignSheetRows(sheet.dataRowCount)}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Which branch the file's quantities are counted at.
///
/// A list rather than a box to type in. The importer matches a branch by name
/// exactly, so a name that is close but not equal loses every quantity in the
/// file -- and says so once per product, which on a real catalogue is hundreds
/// of identical failures for one typo.
class _BranchPickerCard extends StatelessWidget {
  final List<BranchEntity> branches;
  final String selected;
  final bool loading;
  final bool noBranchesAtAll;
  final ValueChanged<String> onChanged;

  const _BranchPickerCard({
    required this.branches,
    required this.selected,
    required this.loading,
    required this.noBranchesAtAll,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final warn = noBranchesAtAll || selected.trim().isEmpty;

    // A name that is no longer among the branches must not sit in the box
    // looking chosen.
    final value = branches.any((b) => b.name == selected) ? selected : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: warn
              ? AppThemeTokens.error.withOpacity(0.4)
              : AppThemeTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.foreignBranchTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            noBranchesAtAll ? l.foreignNoBranches : l.foreignBranchHint,
            style: TextStyle(
              fontSize: 11,
              color: warn
                  ? AppThemeTokens.error
                  : AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (branches.isNotEmpty)
            DropdownButtonFormField<String>(
              value: value,
              isDense: true,
              hint: Text(
                l.foreignBranchPick,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppThemeTokens.inputFill,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppThemeTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppThemeTokens.border),
                ),
              ),
              items: branches
                  .map(
                    (branch) => DropdownMenuItem(
                      value: branch.name,
                      child: Text(
                        branch.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (picked) {
                if (picked != null) onChanged(picked);
              },
            ),
        ],
      ),
    );
  }
}

class _TextFieldCard extends StatefulWidget {
  final String title;
  final String hint;
  final String value;
  final bool warn;
  final ValueChanged<String> onChanged;

  const _TextFieldCard({
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.warn = false,
  });

  @override
  State<_TextFieldCard> createState() => _TextFieldCardState();
}

class _TextFieldCardState extends State<_TextFieldCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_TextFieldCard old) {
    super.didUpdateWidget(old);

    // Changing sheet offers a different category, and it arrives from outside
    // the field rather than through a keystroke.
    if (widget.value != old.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(
          color: widget.warn
              ? AppThemeTokens.error.withOpacity(0.4)
              : AppThemeTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.hint,
            style: TextStyle(
              fontSize: 11,
              color: widget.warn
                  ? AppThemeTokens.error
                  : AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppThemeTokens.inputFill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppThemeTokens.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_excel_parsed_file_entity.dart';
import '../../domain/entities/supplier_excel_row_entity.dart';
import '../../domain/entities/supplier_excel_section.dart';
import '../bloc/supplier_excel_import_bloc.dart';
import '../bloc/supplier_excel_import_event.dart';
import '../utils/supplier_excel_import_i18n.dart';

class SupplierExcelPreviewList extends StatelessWidget {
  final SupplierExcelParsedFileEntity parsedFile;

  const SupplierExcelPreviewList({
    super.key,
    required this.parsedFile,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);

    if (!parsedFile.hasRows) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Text(
          l.noRows,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final errorRows = [
      for (final section in SupplierExcelSectionX.importSections)
        ...parsedFile.rowsFor(section).where((row) => !row.isValid),
    ];

    final warningRows = [
      for (final section in SupplierExcelSectionX.importSections)
        ...parsedFile.rowsFor(section).where((row) => row.hasWarnings),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errorRows.isNotEmpty) ...[
          SupplierExcelIssuesCard(
            title: l.errorsFound,
            rows: errorRows,
            isError: true,
          ),
          const SizedBox(height: 14),
        ],
        if (warningRows.isNotEmpty) ...[
          SupplierExcelIssuesCard(
            title: l.warningsFound,
            rows: warningRows,
            isError: false,
          ),
          const SizedBox(height: 14),
        ],
        _WorkbookOverviewCard(parsedFile: parsedFile),
      ],
    );
  }
}

class SupplierExcelIssuesCard extends StatelessWidget {
  final String title;
  final List<SupplierExcelRowEntity> rows;
  final bool isError;

  const SupplierExcelIssuesCard({
    super.key,
    required this.title,
    required this.rows,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final color = isError ? AppThemeTokens.error : Colors.orange;
    final issues = <_IssueView>[];

    for (final row in rows) {
      final messages = isError ? row.errors : row.warnings;
      for (final message in messages) {
        issues.add(
          _IssueView(
            row: row,
            message: message,
            columnKey: _guessColumnKey(message),
          ),
        );
      }
    }

    final issuesBySection = <SupplierExcelSection, List<_IssueView>>{};
    for (final issue in issues) {
      issuesBySection.putIfAbsent(issue.row.section, () => []).add(issue);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.report_problem_outlined : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${issues.length})',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isError ? l.fixInExcelHint : l.warningHint,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          ...issuesBySection.entries.map((entry) {
            return _IssueSectionTile(
              section: entry.key,
              issues: entry.value,
              color: color,
              isError: isError,
            );
          }),
        ],
      ),
    );
  }

  String _guessColumnKey(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('category name')) return 'name';
    if (normalized.contains('subcategory')) return 'subcategory';
    if (normalized.contains('category')) return 'category';
    if (normalized.contains('branch name')) return 'branchname';
    if (normalized.contains('branch/product') || normalized.contains('branch')) {
      return 'branch';
    }
    if (normalized.contains('product name') || normalized.contains('product')) {
      return 'productname';
    }
    if (normalized.contains('description')) return 'description';
    if (normalized.contains('country id')) return 'countryid';
    if (normalized.contains('country code')) return 'countrycode';
    if (normalized.contains('country name')) return 'countryname';
    if (normalized.contains('region id')) return 'regionid';
    if (normalized.contains('region name')) return 'regionname';
    if (normalized.contains('city')) return 'city';
    if (normalized.contains('address')) return 'address';
    if (normalized.contains('phone')) return 'phone';
    if (normalized.contains('price')) return 'price';
    if (normalized.contains('moq')) return 'moq';
    if (normalized.contains('stock')) return 'stockquantity';
    if (normalized.contains('status')) return 'status';
    if (normalized.contains('rule name')) return 'rulename';
    if (normalized.contains('rate')) return 'rate';
    if (normalized.contains('applies to shipping')) return 'appliestoshipping';
    if (normalized.contains('active')) return 'active';
    if (normalized.contains('type')) return 'type';
    if (normalized.contains('cost')) return 'cost';
    if (normalized.contains('estimated delivery')) return 'estimateddeliverytime';
    if (normalized.contains('minimum order')) return 'minimumorderamount';
    if (normalized.contains('free shipping')) return 'freeshippingthreshold';
    if (normalized.contains('coupon code')) return 'code';
    if (normalized.contains('discount type')) return 'discounttype';
    if (normalized.contains('discount value')) return 'discountvalue';
    if (normalized.contains('max uses')) return 'maxuses';
    if (normalized.contains('start') || normalized.contains('starts at')) return 'startsat';
    if (normalized.contains('expire') || normalized.contains('end')) return 'expiresat';
    return '';
  }
}

class _IssueSectionTile extends StatelessWidget {
  final SupplierExcelSection section;
  final List<_IssueView> issues;
  final Color color;
  final bool isError;

  const _IssueSectionTile({
    required this.section,
    required this.issues,
    required this.color,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final initiallyExpanded = isError;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            '${l.sectionTitle(section.name)} • ${issues.length}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            section.sheetName,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: <Widget>[
            ...issues.take(20).map((issue) {
              return _IssueRowTile(
                issue: issue,
                color: color,
              );
            }),
            if (issues.length > 20)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${issues.length - 20} ${l.moreIssues}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IssueRowTile extends StatelessWidget {
  final _IssueView issue;
  final Color color;

  const _IssueRowTile({
    required this.issue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
    final columnLabel = issue.columnKey.isEmpty
        ? l.unknownColumn
        : l.headerLabel(issue.columnKey);
    final location = '${issue.row.section.sheetName} • ${l.rowNumber(issue.row.rowNumber)} • ${l.columnLabel}: $columnLabel';

    return InkWell(
      onTap: () => _showIssueDetails(context, issue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppThemeTokens.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.issueMessage(issue.message),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppThemeTokens.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showIssueDetails(BuildContext context, _IssueView issue) {
    final l = SupplierExcelImportI18n(context);
    final columnLabel = issue.columnKey.isEmpty
        ? l.unknownColumn
        : l.headerLabel(issue.columnKey);
    final location = '${issue.row.section.sheetName} • ${l.rowNumber(issue.row.rowNumber)} • ${l.columnLabel}: $columnLabel';
    final copyText = '${issue.row.section.sheetName} row ${issue.row.rowNumber} column $columnLabel';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.issueDetailsTitle,
                  style: TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailLine(label: l.excelLocation, value: location),
                const SizedBox(height: 10),
                _DetailLine(label: l.problem, value: l.issueMessage(issue.message)),
                const SizedBox(height: 14),
                Text(
                  l.issueFixInstruction,
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: copyText));
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.locationCopied)),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(
                          l.copyLocation,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _showEditRowSheet(
                            context: context,
                            issue: issue,
                            highlightedColumnKey: issue.columnKey,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(
                          l.editRow,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditRowSheet({
    required BuildContext context,
    required _IssueView issue,
    required String highlightedColumnKey,
  }) {
    final l = SupplierExcelImportI18n(context);
    final bloc = context.read<SupplierExcelImportBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final orderedKeys = _orderedRowKeys(issue.row);
    final controllers = <String, TextEditingController>{
      for (final key in orderedKeys)
        key: TextEditingController(text: issue.row.values[key] ?? ''),
    };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
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
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.editRowTitle,
                              style: TextStyle(
                                color: AppThemeTokens.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${issue.row.section.sheetName} • ${l.rowNumber(issue.row.rowNumber)}',
                              style: TextStyle(
                                color: AppThemeTokens.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.error.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppThemeTokens.error.withOpacity(0.20)),
                    ),
                    child: Text(
                      l.issueMessage(issue.message),
                      style: TextStyle(
                        color: AppThemeTokens.error,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.editRowInstruction,
                    style: TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: orderedKeys.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final key = orderedKeys[index];
                        final isHighlighted = key == highlightedColumnKey;
                        return TextField(
                          controller: controllers[key],
                          textInputAction: TextInputAction.next,
                          keyboardType: _keyboardTypeForKey(key),
                          minLines: key == 'description' || key == 'notes' ? 2 : 1,
                          maxLines: key == 'description' || key == 'notes' ? 4 : 1,
                          decoration: InputDecoration(
                            labelText: l.headerLabel(key),
                            helperText: isHighlighted ? l.fieldWithIssue : null,
                            filled: true,
                            fillColor: isHighlighted
                                ? AppThemeTokens.error.withOpacity(0.05)
                                : AppThemeTokens.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                              borderSide: BorderSide(
                                color: isHighlighted ? AppThemeTokens.error : AppThemeTokens.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                              borderSide: BorderSide(
                                color: isHighlighted ? AppThemeTokens.error : AppThemeTokens.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
                              borderSide: BorderSide(
                                color: isHighlighted
                                    ? AppThemeTokens.error
                                    : Theme.of(context).colorScheme.primary,
                                width: 1.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(
                            l.cancel,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final updatedValues = Map<String, String>.from(issue.row.values);
                            for (final entry in controllers.entries) {
                              updatedValues[entry.key] = entry.value.text.trim();
                            }

                            Navigator.of(sheetContext).pop();

                            // Dispatch after the bottom sheet is removed. This prevents
                            // Flutter from rebuilding/deactivating the preview list while
                            // the sheet's TextFields are still mounted, which can trigger
                            // the framework `_dependents.isEmpty` assertion on some devices.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              bloc.add(
                                SupplierExcelRowUpdated(
                                  section: issue.row.section,
                                  rowNumber: issue.row.rowNumber,
                                  values: updatedValues,
                                ),
                              );

                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(l.rowUpdated)),
                              );
                            });
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            l.saveRow,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Dispose after route teardown fully completes. This is safer for Android
      // keyboards/TextFields when the sheet is closed immediately after saving.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final controller in controllers.values) {
          controller.dispose();
        }
      });
    });
  }

  List<String> _orderedRowKeys(SupplierExcelRowEntity row) {
    final expected = _headersForSection(row.section)
        .map(SupplierExcelRowEntity.normalizeHeader)
        .where((key) => key.isNotEmpty)
        .toList(growable: true);

    for (final key in row.values.keys) {
      if (!expected.contains(key)) expected.add(key);
    }

    return expected;
  }

  List<String> _headersForSection(SupplierExcelSection section) {
    switch (section) {
      case SupplierExcelSection.categories:
        return const ['Name', 'Status'];
      case SupplierExcelSection.subCategories:
        return const ['Category', 'SubCategory', 'Status'];
      case SupplierExcelSection.branches:
        return const ['Branch Name', 'Country Code', 'Region ID', 'City', 'Address', 'Phone', 'Status'];
      case SupplierExcelSection.products:
        return const ['Product Name', 'Description', 'Category', 'SubCategory', 'Price', 'MOQ', 'Status', 'Image Url'];
      case SupplierExcelSection.inventory:
        return const ['Branch', 'Product Name', 'Stock Quantity'];
      case SupplierExcelSection.taxRules:
        return const ['Rule Name', 'Rate', 'Country ID', 'Country Name', 'Region ID', 'Region Name', 'Applies To Shipping', 'Active', 'Notes'];
      case SupplierExcelSection.shippingMethods:
        return const ['Name', 'Type', 'Country ID', 'Country Name', 'Region ID', 'Region Name', 'Cost', 'Estimated Delivery Time', 'Minimum Order Amount', 'Free Shipping Threshold', 'Branch Scope', 'Branch Names', 'Active', 'Notes'];
      case SupplierExcelSection.coupons:
        return const ['Code', 'Description', 'Discount Type', 'Discount Value', 'Max Uses', 'Min Order Amount', 'Max Discount Amount', 'Starts At', 'Expires At', 'Branch Scope', 'Branch Names', 'Active'];
    }
  }

  TextInputType _keyboardTypeForKey(String key) {
    const numericKeys = {
      'price',
      'moq',
      'stockquantity',
      'regionid',
      'countryid',
      'rate',
      'cost',
      'minimumorderamount',
      'freeshippingthreshold',
      'discountvalue',
      'maxuses',
      'minorderamount',
      'maxdiscountamount',
    };

    if (numericKeys.contains(key)) {
      return const TextInputType.numberWithOptions(decimal: true);
    }

    if (key == 'description' || key == 'notes') {
      return TextInputType.multiline;
    }

    return TextInputType.text;
  }
}

class _WorkbookOverviewCard extends StatelessWidget {
  final SupplierExcelParsedFileEntity parsedFile;

  const _WorkbookOverviewCard({required this.parsedFile});

  @override
  Widget build(BuildContext context) {
    final l = SupplierExcelImportI18n(context);
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
          Text(
            l.workbookSummary,
            style: TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            parsedFile.canImport ? l.readyToImport : l.fixExcelFile,
            style: TextStyle(
              color: parsedFile.canImport ? primary : AppThemeTokens.error,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SupplierExcelSectionX.importSections.map((section) {
              final rows = parsedFile.rowsFor(section);
              if (rows.isEmpty) return const SizedBox.shrink();
              final issueCount = rows.fold<int>(
                0,
                (total, row) => total + row.errors.length,
              );
              final color = issueCount > 0 ? AppThemeTokens.error : primary;

              return Chip(
                avatar: Icon(
                  issueCount > 0
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  size: 18,
                  color: color,
                ),
                label: Text(
                  issueCount > 0
                      ? '${l.sectionTitle(section.name)}: $issueCount ${l.errors.toLowerCase()}'
                      : '${l.sectionTitle(section.name)}: ${rows.length}',
                ),
                labelStyle: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
                backgroundColor: color.withOpacity(0.08),
                side: BorderSide(color: color.withOpacity(0.22)),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
            label,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueView {
  final SupplierExcelRowEntity row;
  final String message;
  final String columnKey;

  const _IssueView({
    required this.row,
    required this.message,
    required this.columnKey,
  });
}

import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import '../../domain/entities/tax_rule_entity.dart';
import '../bloc/tax_rules_bloc.dart';
import '../bloc/tax_rules_event.dart';
import '../bloc/tax_rules_state.dart';
import '../widgets/tax_rule_card.dart';

enum _TaxStatusFilter {
  enabled,
  disabled,
  all,
}

class TaxRulesScreen extends StatelessWidget {
  const TaxRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaxRulesBloc>(
      create: (_) => sl<TaxRulesBloc>()..add(const LoadTaxRulesRequested()),
      child: const _TaxRulesView(),
    );
  }
}

class _TaxRulesView extends StatefulWidget {
  const _TaxRulesView();

  @override
  State<_TaxRulesView> createState() => _TaxRulesViewState();
}

class _TaxRulesViewState extends State<_TaxRulesView> {
  String _searchQuery = '';
  _TaxStatusFilter _statusFilter = _TaxStatusFilter.enabled;

  List<TaxRuleEntity> _filteredRules(List<TaxRuleEntity> rules) {
    final query = _searchQuery.trim().toLowerCase();

    return rules.where((rule) {
      final matchesStatus = switch (_statusFilter) {
        _TaxStatusFilter.enabled => rule.active,
        _TaxStatusFilter.disabled => !rule.active,
        _TaxStatusFilter.all => true,
      };

      if (!matchesStatus) return false;

      if (query.isEmpty) return true;

      return rule.ruleName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<TaxRulesBloc>().add(const LoadTaxRulesRequested());
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaxRuleEntity rule,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.supplierDeleteTaxRule,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            context.l10n.supplierDeleteTaxRuleConfirmation(rule.ruleName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(
                context.l10n.deleteButton,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<TaxRulesBloc>().add(DeleteTaxRuleRequested(rule.id));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<TaxRulesBloc, TaxRulesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
          context.read<TaxRulesBloc>().add(
                const ClearTaxRuleMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(
            context,
            localizeSupplierSuccessMessage(context, state.successMessage!),
          );
          context.read<TaxRulesBloc>().add(
                const ClearTaxRuleMessageRequested(),
              );
        }
      },
      child: Scaffold(
        backgroundColor: AppThemeTokens.background,
        drawer: const SupplierAppDrawer(),
        appBar: AppBar(
          backgroundColor: AppThemeTokens.background,
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          title: Text(
            context.l10n.supplierTaxConfiguration,
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.supplierCreateTaxRule,
              onPressed: () => context.go('/supplier-tax-rules/create'),
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: context.l10n.refreshButton,
              onPressed: () => _refresh(context),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<TaxRulesBloc, TaxRulesState>(
            builder: (context, state) {
              final filteredRules = _filteredRules(state.rules);

              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppThemeTokens.screenHorizontalPadding,
                    16,
                    AppThemeTokens.screenHorizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderCard(primary: primary),
                      const SizedBox(height: 18),
                      _StatusFilterBar(
                        selected: _statusFilter,
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _SearchField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(count: filteredRules.length),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const _LoadingCard()
                      else if (state.errorMessage != null)
                        _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () => _refresh(context),
                        )
                      else if (state.rules.isEmpty)
                        _EmptyCard(primary: primary)
                      else if (filteredRules.isEmpty)
                        _NoSearchResultsCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredRules.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final rule = filteredRules[index];

                            return TaxRuleCard(
                              rule: rule,
                              onEdit: () {
                                context.go(
                                  '/supplier-tax-rules/edit',
                                  extra: rule,
                                );
                              },
                              onDelete: () {
                                _confirmDelete(context, rule);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final _TaxStatusFilter selected;
  final ValueChanged<_TaxStatusFilter> onChanged;

  const _StatusFilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusFilterButton(
          label: context.l10n.supplierEnabledOnly,
          selected: selected == _TaxStatusFilter.enabled,
          onTap: () => onChanged(_TaxStatusFilter.enabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: context.l10n.supplierDisabledOnly,
          selected: selected == _TaxStatusFilter.disabled,
          onTap: () => onChanged(_TaxStatusFilter.disabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: context.l10n.allLabel,
          selected: selected == _TaxStatusFilter.all,
          onTap: () => onChanged(_TaxStatusFilter.all),
        ),
      ],
    );
  }
}

class _StatusFilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor:
                selected ? Colors.white : AppThemeTokens.textPrimary,
            backgroundColor: selected ? primary : AppThemeTokens.surface,
            side: BorderSide(
              color: selected ? primary : AppThemeTokens.border,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Color primary;

  const _HeaderCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.percent_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.supplierManageTaxRules,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  context.l10n.supplierConfigureOrderLevelTaxByCountryAndRegionRetailerCheckoutWillUseTheseRulesToCalculateTax,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: context.l10n.supplierSearchTaxRules,
        hintStyle: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppThemeTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppThemeTokens.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.supplierTaxRuleList,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.supplierRulesShown(count),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
          const Icon(Icons.error_outline, color: Colors.red, size: 34),
          const SizedBox(height: 12),
          Text(
            context.l10n.supplierCouldNotLoadTaxRules,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              context.l10n.retryButton,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final Color primary;

  const _EmptyCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.percent_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.supplierNoTaxRulesYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.supplierCreateTaxRulesFromTheSupplierDashboardQuickActionOrTapThePlusIconAbove,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  final Color primary;

  const _NoSearchResultsCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: primary, size: 34),
          const SizedBox(height: 12),
          Text(
            context.l10n.supplierNoMatchingTaxRules,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
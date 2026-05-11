import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/promotion_entity.dart';
import '../bloc/promotions_bloc.dart';
import '../bloc/promotions_event.dart';
import '../bloc/promotions_state.dart';
import '../widgets/promotion_card.dart';

enum _PromotionStatusFilter {
  enabled,
  disabled,
  all,
}

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromotionsBloc>(
      create: (_) => sl<PromotionsBloc>()..add(const LoadPromotionsRequested()),
      child: const _PromotionsView(),
    );
  }
}

class _PromotionsView extends StatefulWidget {
  const _PromotionsView();

  @override
  State<_PromotionsView> createState() => _PromotionsViewState();
}

class _PromotionsViewState extends State<_PromotionsView> {
  String _searchQuery = '';
  _PromotionStatusFilter _statusFilter = _PromotionStatusFilter.enabled;

  List<PromotionEntity> _filteredPromotions(
    List<PromotionEntity> promotions,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return promotions.where((promotion) {
      final matchesStatus = switch (_statusFilter) {
        _PromotionStatusFilter.enabled => promotion.active,
        _PromotionStatusFilter.disabled => !promotion.active,
        _PromotionStatusFilter.all => true,
      };

      if (!matchesStatus) return false;

      if (query.isEmpty) return true;

      return promotion.title.toLowerCase().contains(query) ||
          (promotion.description ?? '').toLowerCase().contains(query) ||
          promotion.discountLabel.toLowerCase().contains(query) ||
          promotion.discountTypeLabel.toLowerCase().contains(query) ||
          promotion.targetLabel.toLowerCase().contains(query) ||
          promotion.branchScopeLabel.toLowerCase().contains(query) ||
          promotion.statusLabel.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<PromotionsBloc>().add(const LoadPromotionsRequested());
  }

  Future<void> _copyTitle(BuildContext context, String title) async {
    await Clipboard.setData(ClipboardData(text: title));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promotion title copied')),
    );
  }

  Future<void> _confirmDeletePromotion(
    BuildContext context,
    PromotionEntity promotion,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Promotion',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete "${promotion.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<PromotionsBloc>().add(
          DeletePromotionRequested(promotion.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<PromotionsBloc, PromotionsState>(
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          context.read<PromotionsBloc>().add(
                const ClearPromotionMessageRequested(),
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
            'Promotions',
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Create Promotion',
              onPressed: () => context.go('/supplier-promotions/create'),
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _refresh(context),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<PromotionsBloc, PromotionsState>(
            builder: (context, state) {
              final filteredPromotions =
                  _filteredPromotions(state.promotions);

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
                      _SectionHeader(count: filteredPromotions.length),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const _LoadingCard()
                      else if (state.errorMessage != null)
                        _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () => _refresh(context),
                        )
                      else if (state.promotions.isEmpty)
                        _EmptyPromotionsCard(primary: primary)
                      else if (filteredPromotions.isEmpty)
                        _NoSearchResultsCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredPromotions.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final promotion = filteredPromotions[index];

                            return PromotionCard(
                              promotion: promotion,
                              onCopy: () => _copyTitle(
                                context,
                                promotion.title,
                              ),
                              onEdit: () {
                                context.go(
                                  '/supplier-promotions/edit',
                                  extra: promotion,
                                );
                              },
                              onDelete: () {
                                _confirmDeletePromotion(context, promotion);
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
  final _PromotionStatusFilter selected;
  final ValueChanged<_PromotionStatusFilter> onChanged;

  const _StatusFilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusFilterButton(
          label: 'Enabled only',
          selected: selected == _PromotionStatusFilter.enabled,
          onTap: () => onChanged(_PromotionStatusFilter.enabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: 'Disabled only',
          selected: selected == _PromotionStatusFilter.disabled,
          onTap: () => onChanged(_PromotionStatusFilter.disabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: 'All',
          selected: selected == _PromotionStatusFilter.all,
          onTap: () => onChanged(_PromotionStatusFilter.all),
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
              Icons.local_offer_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Promotions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'View, search, create, edit, and delete supplier wholesale promotions for products, categories, subcategories, or all products.',
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
        hintText: 'Search promotions',
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
        const Text(
          'Promotion List',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count promotion${count == 1 ? '' : 's'} shown',
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
          const Text(
            'Could not load promotions',
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
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPromotionsCard extends StatelessWidget {
  final Color primary;

  const _EmptyPromotionsCard({required this.primary});

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
              Icons.local_offer_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No promotions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create promotions from the supplier dashboard quick action or tap the plus icon above.',
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
          const Text(
            'No matching promotions',
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
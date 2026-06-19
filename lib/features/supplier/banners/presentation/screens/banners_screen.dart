import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/widgets/app_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../../shared/utils/supplier_success_message_localizer.dart';
import '../../domain/entities/banner_entity.dart';
import '../bloc/banners_bloc.dart';
import '../bloc/banners_event.dart';
import '../bloc/banners_state.dart';
import '../widgets/banner_card.dart';

enum _BannerStatusFilter {
  enabled,
  disabled,
  all,
}

class BannersScreen extends StatelessWidget {
  const BannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BannersBloc>(
      create: (_) => sl<BannersBloc>()..add(const LoadBannersRequested()),
      child: const _BannersView(),
    );
  }
}

class _BannersView extends StatefulWidget {
  const _BannersView();

  @override
  State<_BannersView> createState() => _BannersViewState();
}

class _BannersViewState extends State<_BannersView> {
  String _searchQuery = '';
  _BannerStatusFilter _statusFilter = _BannerStatusFilter.enabled;

  List<BannerEntity> _filteredBanners(
    BuildContext context,
    List<BannerEntity> banners,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return banners.where((banner) {
      final matchesStatus = switch (_statusFilter) {
        _BannerStatusFilter.enabled => banner.active,
        _BannerStatusFilter.disabled => !banner.active,
        _BannerStatusFilter.all => true,
      };

      if (!matchesStatus) return false;
      if (query.isEmpty) return true;

      return banner.title.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<BannersBloc>().add(const LoadBannersRequested());
  }

  Future<void> _confirmDeleteBanner(
    BuildContext context,
    BannerEntity banner,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.supplierDeleteBanner,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            context.l10n.supplierDeleteBannerConfirmation(banner.title),
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
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    context.read<BannersBloc>().add(
          DeleteBannerRequested(banner.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocListener<BannersBloc, BannersState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
              );
          return;
        }

        if (state.successMessage != null) {
          AppToast.success(
            context,
            localizeSupplierSuccessMessage(context, state.successMessage!),
          );
          context.read<BannersBloc>().add(
                const ClearBannerMessageRequested(),
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
            context.l10n.supplierHomeBanners,
            style: TextStyle(
              color: primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.supplierCreateBanner,
              onPressed: () => context.go('/supplier-banners/create'),
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
          child: BlocBuilder<BannersBloc, BannersState>(
            builder: (context, state) {
              final filteredBanners = _filteredBanners(context, state.banners);

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
                      _SectionHeader(count: filteredBanners.length),
                      const SizedBox(height: 12),
                      if (state.loading)
                        const _LoadingCard()
                      else if (state.errorMessage != null)
                        _ErrorCard(
                          message: state.errorMessage!,
                          onRetry: () => _refresh(context),
                        )
                      else if (state.banners.isEmpty)
                        _EmptyBannersCard(primary: primary)
                      else if (filteredBanners.isEmpty)
                        _NoSearchResultsCard(primary: primary)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredBanners.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            final banner = filteredBanners[index];

                            return BannerCard(
                              banner: banner,
                              onEdit: () {
                                context.go(
                                  '/supplier-banners/edit',
                                  extra: banner,
                                );
                              },
                              onDelete: () {
                                _confirmDeleteBanner(context, banner);
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
  final _BannerStatusFilter selected;
  final ValueChanged<_BannerStatusFilter> onChanged;

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
          selected: selected == _BannerStatusFilter.enabled,
          onTap: () => onChanged(_BannerStatusFilter.enabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: context.l10n.supplierDisabledOnly,
          selected: selected == _BannerStatusFilter.disabled,
          onTap: () => onChanged(_BannerStatusFilter.disabled),
        ),
        const SizedBox(width: 8),
        _StatusFilterButton(
          label: context.l10n.allLabel,
          selected: selected == _BannerStatusFilter.all,
          onTap: () => onChanged(_BannerStatusFilter.all),
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
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
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(
              Icons.image_outlined,
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
                  context.l10n.supplierManageHomeBanners,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.supplierBannersDescription,
                  style: const TextStyle(
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

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: _localizedSearchBannersHint(context),
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
          context.l10n.supplierBannerList,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _localizedBannersShown(context, count),
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
            context.l10n.supplierCouldNotLoadBanners,
            style: const TextStyle(
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
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBannersCard extends StatelessWidget {
  final Color primary;

  const _EmptyBannersCard({required this.primary});

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
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(
              Icons.image_outlined,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.supplierNoBannersYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.supplierCreateBannersFromDashboard,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
            context.l10n.supplierNoMatchingBanners,
            style: const TextStyle(
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

String _localizedSearchBannersHint(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;

  switch (languageCode) {
    case 'ar':
      return 'البحث في البانرات';
    case 'fr':
      return 'Rechercher des bannières';
    default:
      return 'Search banners';
  }
}

String _localizedBannersShown(BuildContext context, int count) {
  final languageCode = Localizations.localeOf(context).languageCode;

  switch (languageCode) {
    case 'ar':
      return 'عدد البانرات المعروضة: $count';
    case 'fr':
      return 'Bannières affichées : $count';
    default:
      return 'Banners shown: $count';
  }
}

String _localizedTargetLabel(BuildContext context, String label) {
  switch (label) {
    case 'Product':
      return context.l10n.productLabel;
    case 'Category':
      return context.l10n.categoryLabel;
    case 'Subcategory':
      return context.l10n.subcategoryLabel;
    case 'URL':
      return context.l10n.urlLabel;
    case 'No target':
      return context.l10n.supplierNoTarget;
    default:
      return label;
  }
}

String _localizedStatusLabel(BuildContext context, String label) {
  switch (label.toLowerCase()) {
    case 'active':
      return context.l10n.activeStatus;
    case 'inactive':
      return context.l10n.inactiveStatus;
    case 'scheduled':
      return context.l10n.supplierScheduled;
    case 'expired':
      return context.l10n.supplierExpired;
    default:
      return label;
  }
}

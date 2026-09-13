import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/utils/responsive_grid.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_dashboard_stat_card.dart';
import '../cubit/supplier_statistics_cubit.dart';
import '../widgets/supplier_retailer_card.dart';
import '../widgets/supplier_retailer_contact_dialog.dart';

/// The supplier's audience at a glance: how many shops installed the app, and
/// every one of them with the email/phone needed to reach out.
class SupplierStatisticsScreen extends StatelessWidget {
  const SupplierStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierStatisticsCubit>()..load(),
      child: const _SupplierStatisticsView(),
    );
  }
}

class _SupplierStatisticsView extends StatefulWidget {
  const _SupplierStatisticsView();

  @override
  State<_SupplierStatisticsView> createState() =>
      _SupplierStatisticsViewState();
}

class _SupplierStatisticsViewState extends State<_SupplierStatisticsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.surface,
        elevation: 0,
        title: Text(
          l10n.supplierStatisticsTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.supplierStatisticsRefresh,
            onPressed: () =>
                context.read<SupplierStatisticsCubit>().load(refresh: true),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
      body: BlocConsumer<SupplierStatisticsCubit, SupplierStatisticsState>(
        listenWhen: (prev, next) =>
            next.error != null &&
            next.status == SupplierStatisticsStatus.loaded,
        listener: (context, state) {
          // Only surfaced as a toast when content is still on screen; a failed
          // first load gets the full error state below instead.
          AppToast.error(context, state.error!);
          context.read<SupplierStatisticsCubit>().clearError();
        },
        builder: (context, state) {
          if (state.status == SupplierStatisticsStatus.loading ||
              state.status == SupplierStatisticsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SupplierStatisticsStatus.error) {
            return _ErrorView(
              message: state.error ?? l10n.supplierStatisticsLoadFailed,
              onRetry: () => context.read<SupplierStatisticsCubit>().load(),
            );
          }

          final stats = state.statistics;
          final retailers = state.visibleRetailers;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<SupplierStatisticsCubit>().load(refresh: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              // Keeps pull-to-refresh working on a short list.
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Builder(
                  builder: (context) {
                    final tiles = <Widget>[
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsTotalRetailers,
                        value: '${stats.totalRetailers}',
                        icon: Icons.storefront_outlined,
                        iconColor: AppThemeTokens.primary,
                        iconBackgroundColor:
                            AppThemeTokens.primary.withOpacity(0.12),
                      ),
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsNewLast7Days,
                        value: '${stats.newRetailersLast7Days}',
                        icon: Icons.person_add_alt_outlined,
                        iconColor: AppThemeTokens.primary,
                        iconBackgroundColor:
                            AppThemeTokens.primary.withOpacity(0.12),
                      ),
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsNewLast30Days,
                        value: '${stats.newRetailersLast30Days}',
                        icon: Icons.calendar_month_outlined,
                        iconColor: AppThemeTokens.textSecondary,
                        iconBackgroundColor: AppThemeTokens.inputFill,
                      ),
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsActiveLast30Days,
                        value: '${stats.activeLast30Days}',
                        icon: Icons.login_outlined,
                        iconColor: AppThemeTokens.textSecondary,
                        iconBackgroundColor: AppThemeTokens.inputFill,
                      ),
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsCompleteProfiles,
                        value: '${stats.withCompleteProfile}',
                        icon: Icons.badge_outlined,
                        iconColor: AppThemeTokens.textSecondary,
                        iconBackgroundColor: AppThemeTokens.inputFill,
                      ),
                      SupplierDashboardStatCard(
                        title: l10n.supplierStatisticsReachableTitle,
                        value: '${stats.reachableRetailers}',
                        icon: Icons.contact_phone_outlined,
                        iconColor: AppThemeTokens.primary,
                        iconBackgroundColor:
                            AppThemeTokens.primary.withOpacity(0.12),
                      ),
                    ];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tiles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: responsiveGridColumns(
                              constraints.maxWidth,
                              targetCardWidth: 190,
                            ),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            // Fixed height, per responsiveGridColumns' note:
                            // a card sized by aspect ratio turns into a mostly
                            // empty box on a wide window.
                            mainAxisExtent: 74,
                          ),
                          itemBuilder: (context, index) => tiles[index],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                _ReachabilityCard(
                  reachable: stats.reachableRetailers,
                  total: stats.totalRetailers,
                  withEmail: stats.withEmail,
                  withPhone: stats.withPhone,
                  rate: stats.reachableRate,
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.supplierStatisticsRetailersSectionTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppThemeTokens.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${retailers.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),

                if (stats.totalRetailers > 0) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        context.read<SupplierStatisticsCubit>().search(v),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.supplierStatisticsSearchHint,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppThemeTokens.textSecondary,
                      ),
                      suffixIcon: state.query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<SupplierStatisticsCubit>()
                                    .search('');
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppThemeTokens.textSecondary,
                              ),
                            ),
                      filled: true,
                      fillColor: AppThemeTokens.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppThemeTokens.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppThemeTokens.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppThemeTokens.primary,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                if (retailers.isEmpty)
                  _EmptyView(
                    message: stats.isEmpty
                        ? l10n.supplierStatisticsEmpty
                        : l10n.supplierStatisticsNoSearchResults,
                  )
                else
                  ...retailers.map(
                    (retailer) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SupplierRetailerCard(
                        retailer: retailer,
                        onTap: () => showSupplierRetailerContactDialog(
                          context,
                          retailer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// How much of the audience the supplier can actually reach -- the number that
/// decides whether the list below is useful to them at all.
class _ReachabilityCard extends StatelessWidget {
  final int reachable;
  final int total;
  final int withEmail;
  final int withPhone;
  final double rate;

  const _ReachabilityCard({
    required this.reachable,
    required this.total,
    required this.withEmail,
    required this.withPhone,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(12),
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
              Expanded(
                child: Text(
                  l10n.supplierStatisticsReachableTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              Text(
                '$reachable/$total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: AppThemeTokens.inputFill,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppThemeTokens.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: AppThemeTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.supplierStatisticsWithEmail(withEmail),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.call_outlined,
                size: 16,
                color: AppThemeTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.supplierStatisticsWithPhone(withPhone),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 42,
            color: AppThemeTokens.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppThemeTokens.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.supplierStatisticsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

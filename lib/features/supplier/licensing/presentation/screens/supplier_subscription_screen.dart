import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../domain/entities/owner_app_access.dart';
import '../cubit/supplier_subscription_cubit.dart';
import '../cubit/supplier_subscription_state.dart';
import '../widgets/supplier_upgrade_sheet.dart';

class SupplierSubscriptionScreen extends StatelessWidget {
  const SupplierSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierSubscriptionCubit>()..load(),
      child: const _SubscriptionView(),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppThemeTokens.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          l10n.licensingTitle,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocBuilder<SupplierSubscriptionCubit, SupplierSubscriptionState>(
        builder: (context, state) {
          if (state.isLoading && state.access == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.access == null) {
            return _ErrorView(
              message: state.errorMessage!,
              retryLabel: l10n.retry,
              onRetry: () => context.read<SupplierSubscriptionCubit>().load(),
            );
          }

          final access = state.access;
          return RefreshIndicator(
            color: AppThemeTokens.primary,
            onRefresh: () => context.read<SupplierSubscriptionCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                  AppThemeTokens.screenHorizontalPadding),
              children: [
                if (access != null) _CurrentPlanCard(access: access, l10n: l10n),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppThemeTokens.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.upgrade_rounded),
                    label: Text(l10n.licensingUpgrade),
                    onPressed: () async {
                      final upgraded =
                          await SupplierUpgradeSheet.show(context);
                      if (upgraded == true && context.mounted) {
                        context.read<SupplierSubscriptionCubit>().refresh();
                      }
                    },
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

class _CurrentPlanCard extends StatelessWidget {
  final OwnerAppAccess access;
  final AppLocalizations l10n;

  const _CurrentPlanCard({required this.access, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.licensingCurrentPlan,
              style: const TextStyle(
                  color: AppThemeTokens.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            access.planName ?? access.planCode?.name ?? '—',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary),
          ),
          const SizedBox(height: 12),
          _row(l10n.licensingStatus,
              access.subscriptionStatus?.name ?? '—'),
          _row(l10n.licensingDaysLeft, '${access.daysLeft}'),
          if (access.usersAllowed != null)
            _row(l10n.licensingUsers,
                '${access.activeUsers} / ${access.usersAllowed}'),
          if (access.hasPendingUpgradeRequest) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeTokens.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(l10n.licensingUpgradePending,
                  style: const TextStyle(
                      color: AppThemeTokens.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppThemeTokens.textSecondary)),
          Text(value,
              style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppThemeTokens.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppThemeTokens.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppThemeTokens.primary),
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

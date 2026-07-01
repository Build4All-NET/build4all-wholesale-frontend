import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/payments/wholesale_stripe_payment_sheet.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/billing_cycle.dart';
import '../bloc/upgrade_flow_bloc.dart';
import '../bloc/upgrade_flow_event.dart';
import '../bloc/upgrade_flow_state.dart';

/// Bottom sheet driving the paid upgrade flow. Returns `true` when an upgrade
/// was completed so the caller can refresh the subscription.
class SupplierUpgradeSheet {
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => sl<UpgradeFlowBloc>()..add(const UpgradePlansRequested()),
        child: const _UpgradeSheetView(),
      ),
    );
  }
}

class _UpgradeSheetView extends StatefulWidget {
  const _UpgradeSheetView();

  @override
  State<_UpgradeSheetView> createState() => _UpgradeSheetViewState();
}

class _UpgradeSheetViewState extends State<_UpgradeSheetView> {
  bool _paymentHandled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<UpgradeFlowBloc, UpgradeFlowState>(
      listener: (context, state) async {
        if (state.status == UpgradeFlowStatus.awaitingPayment &&
            !_paymentHandled) {
          _paymentHandled = true;
          await _handlePayment(context, state);
        }

        if (state.status == UpgradeFlowStatus.success) {
          AppToast.success(context, l10n.licensingPaymentSuccess);
          Navigator.of(context).pop(true);
        }

        if (state.status == UpgradeFlowStatus.error &&
            (state.errorMessage ?? '').isNotEmpty) {
          AppToast.error(context, _mapError(l10n, state.errorMessage!));
          _paymentHandled = false;
          context.read<UpgradeFlowBloc>().add(const UpgradeFlowMessagesCleared());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: _buildBody(context, l10n, state),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    UpgradeFlowState state,
  ) {
    if (state.status == UpgradeFlowStatus.loadingPlans) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == UpgradeFlowStatus.plansError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(l10n.licensingNoPlans,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppThemeTokens.textSecondary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context
                .read<UpgradeFlowBloc>()
                .add(const UpgradePlansRequested()),
            child: Text(l10n.retry),
          ),
        ],
      );
    }

    if (state.plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(l10n.licensingNoPlans,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppThemeTokens.textSecondary)),
      );
    }

    final busy = state.isBusy ||
        state.status == UpgradeFlowStatus.awaitingPayment;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppThemeTokens.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(l10n.licensingChoosePlan,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary)),
          const SizedBox(height: 12),

          // Billing cycle selector
          _BillingCycleSelector(
            cycle: state.billingCycle,
            onChanged: (c) => context
                .read<UpgradeFlowBloc>()
                .add(UpgradeBillingCycleSelected(c)),
            monthlyLabel: l10n.licensingBillingMonthly,
            yearlyLabel: l10n.licensingBillingYearly,
          ),
          const SizedBox(height: 12),

          // Plans
          ...state.plans.map((plan) {
            final selected = plan.code == state.selectedPlan;
            final price = state.billingCycle == BillingCycle.YEARLY
                ? plan.pricing.effectiveYearlyPrice
                : plan.pricing.monthlyPrice;
            return _PlanCard(
              title: plan.title ?? plan.code,
              description: plan.description,
              priceLabel: price == null
                  ? '—'
                  : '${plan.pricing.currency} ${price.toStringAsFixed(2)}',
              selected: selected,
              enabled: plan.available,
              onTap: plan.available
                  ? () => context
                      .read<UpgradeFlowBloc>()
                      .add(UpgradePlanSelected(plan.code))
                  : null,
            );
          }),

          const SizedBox(height: 12),
          Text(l10n.licensingPaymentMethod,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.textPrimary)),
          const SizedBox(height: 8),
          ...state.availablePaymentMethods.map((m) {
            final selected = m.selectionCode == state.selectedPaymentMethodCode;
            return RadioListTile<String>(
              value: m.selectionCode,
              groupValue: state.selectedPaymentMethodCode,
              activeColor: AppThemeTokens.primary,
              contentPadding: EdgeInsets.zero,
              title: Text(m.displayName.isNotEmpty ? m.displayName : m.typeName),
              selected: selected,
              onChanged: (v) {
                if (v != null) {
                  context
                      .read<UpgradeFlowBloc>()
                      .add(UpgradePaymentMethodSelected(v));
                }
              },
            );
          }),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeTokens.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: (!state.hasSelection || busy)
                  ? null
                  : () => context
                      .read<UpgradeFlowBloc>()
                      .add(const UpgradePaymentRequested()),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.licensingPayNow),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    UpgradeFlowState state,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<UpgradeFlowBloc>();
    final intent = state.paymentIntent;
    if (intent == null) return;

    final provider = intent.provider.toUpperCase();

    // Stripe → native payment sheet.
    if (provider == 'STRIPE') {
      final result = await WholesaleStripePaymentSheet.present(
        publishableKey: intent.publishableKey ?? '',
        clientSecret: intent.clientSecret ?? '',
        merchantDisplayName: l10n.licensingTitle,
      );
      if (!mounted) return;
      if (result.completed) {
        bloc.add(UpgradePaymentSucceeded(intent.paymentIntentId));
      } else {
        bloc.add(UpgradePaymentFailed(
            result.message ?? l10n.licensingPaymentCancelled));
      }
      return;
    }

    // PayPal / MPGS → open the hosted checkout page, then confirm.
    if (provider == 'PAYPAL' || provider == 'MPGS') {
      final url = (intent.checkoutUrl ?? '').trim();
      if (url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        }
      }
      if (!mounted) return;
      final confirmed = await _confirmPaidDialog(context, l10n);
      if (!mounted) return;
      if (confirmed == true) {
        bloc.add(UpgradePaymentSucceeded(intent.paymentIntentId));
      } else {
        bloc.add(UpgradePaymentFailed(l10n.licensingPaymentCancelled));
      }
      return;
    }

    // Manual / cash → confirm and let the backend finalize.
    final confirmed = await _confirmPaidDialog(context, l10n);
    if (!mounted) return;
    if (confirmed == true) {
      bloc.add(UpgradePaymentSucceeded(intent.paymentIntentId));
    } else {
      bloc.add(UpgradePaymentFailed(l10n.licensingPaymentCancelled));
    }
  }

  Future<bool?> _confirmPaidDialog(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.licensingCompletePaymentTitle),
        content: Text(l10n.licensingCompletePaymentContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.retry),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.licensingIvePaid),
          ),
        ],
      ),
    );
  }

  String _mapError(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'SELECT_PLAN':
        return l10n.licensingSelectPlan;
      case 'SELECT_METHOD':
        return l10n.licensingSelectMethod;
      default:
        return raw;
    }
  }
}

class _BillingCycleSelector extends StatelessWidget {
  final BillingCycle cycle;
  final ValueChanged<BillingCycle> onChanged;
  final String monthlyLabel;
  final String yearlyLabel;

  const _BillingCycleSelector({
    required this.cycle,
    required this.onChanged,
    required this.monthlyLabel,
    required this.yearlyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _seg(monthlyLabel, cycle == BillingCycle.MONTHLY,
            () => onChanged(BillingCycle.MONTHLY)),
        const SizedBox(width: 8),
        _seg(yearlyLabel, cycle == BillingCycle.YEARLY,
            () => onChanged(BillingCycle.YEARLY)),
      ],
    );
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppThemeTokens.primary.withValues(alpha: 0.12)
                : AppThemeTokens.inputFill,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
            border: Border.all(
              color: selected ? AppThemeTokens.primary : AppThemeTokens.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppThemeTokens.primary
                  : AppThemeTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String? description;
  final String priceLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppThemeTokens.primary.withValues(alpha: 0.06)
                : AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
            border: Border.all(
              color: selected ? AppThemeTokens.primary : AppThemeTokens.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppThemeTokens.textPrimary)),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppThemeTokens.textSecondary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(priceLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppThemeTokens.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

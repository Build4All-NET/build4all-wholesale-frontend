import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/supplier_payment_method_entity.dart';
import '../bloc/supplier_payment_methods_bloc.dart';
import '../screens/stripe_config_screen.dart';

class SupplierPaymentMethodCard extends StatelessWidget {
  final SupplierPaymentMethodEntity method;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  const SupplierPaymentMethodCard({
    super.key,
    required this.method,
    required this.isSaving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final outline = theme.colorScheme.outline;

    final isStripe = method.code.toUpperCase() == 'STRIPE';
    final canToggle =
        method.supportedNow && !method.requiresCredentials && !isSaving;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + title + toggle row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconColor(primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon(), color: _iconColor(primary), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      method.helperText,
                      style: TextStyle(
                        color: onSurfaceVariant,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSaving)
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: primary),
                )
              else if (!method.requiresCredentials && method.supportedNow)
                Switch(
                  value: method.projectEnabled,
                  activeColor: primary,
                  onChanged: canToggle ? onChanged : null,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Status chips ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                enabled: method.projectEnabled,
                enabledText: l10n.paymentMethodEnabled,
                disabledText: l10n.paymentMethodDisabled,
                primary: primary,
                onSurfaceVariant: onSurfaceVariant,
              ),
              if (!method.supportedNow)
                _InfoPill(
                  text: l10n.paymentMethodComingSoon,
                  icon: Icons.schedule_rounded,
                ),
              if (method.requiresCredentials && method.supportedNow)
                _InfoPill(
                  text: l10n.paymentMethodCredentialsRequired,
                  icon: Icons.key_rounded,
                ),
            ],
          ),

          // ── Configure button (Stripe only) ──
          if (isStripe && method.supportedNow) ...[
            const SizedBox(height: 14),
            Divider(
                height: 1, color: outline.withOpacity(0.3)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openStripeConfig(context),
                icon: Icon(Icons.settings_rounded, size: 18, color: primary),
                label: Text(
                  _hasCredentials()
                      ? l10n.paymentMethodEditStripe
                      : l10n.paymentMethodConfigureStripe,
                  style: TextStyle(
                      color: primary, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasCredentials() {
    final sk = method.configValues['secretKey']?.toString() ?? '';
    return sk.isNotEmpty && sk != 'null';
  }

  void _openStripeConfig(BuildContext context) {
    final bloc = context.read<SupplierPaymentMethodsBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: StripeConfigScreen(
            currentConfigValues: method.configValues,
            currentlyEnabled: method.projectEnabled,
          ),
        ),
      ),
    );
  }

  String _displayTitle() {
    if (method.code.toUpperCase() == 'MPGS') return 'Credit / Debit Card';
    return method.displayName;
  }

  IconData _icon() {
    switch (method.code.toUpperCase()) {
      case 'CASH':   return Icons.payments_outlined;
      case 'STRIPE': return Icons.credit_card_rounded;
      case 'PAYPAL': return Icons.account_balance_wallet_outlined;
      case 'MPGS':   return Icons.payment_rounded;
      default:       return Icons.account_balance_wallet_outlined;
    }
  }

  Color _iconColor(Color primary) {
    switch (method.code.toUpperCase()) {
      case 'CASH':   return const Color(0xFF16A34A);
      case 'PAYPAL': return const Color(0xFF2563EB);
      default:       return primary;
    }
  }
}

// ─────────────────────────────────────────────────── sub-widgets ──

class _StatusChip extends StatelessWidget {
  final bool enabled;
  final String enabledText;
  final String disabledText;
  final Color primary;
  final Color onSurfaceVariant;

  const _StatusChip({
    required this.enabled,
    required this.enabledText,
    required this.disabledText,
    required this.primary,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF16A34A) : onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        enabled ? enabledText : disabledText,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoPill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: amber.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: amber),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: amber, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}
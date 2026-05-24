import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_payment_method_entity.dart';
import 'payment_method_status_chip.dart';

class SupplierPaymentMethodCard extends StatelessWidget {
  final SupplierPaymentMethodEntity method;
  final bool isSaving;
  final ValueChanged<bool> onChanged;
  final String enabledLabel;
  final String disabledLabel;
  final String comingSoonLabel;
  final String credentialsRequiredLabel;

  const SupplierPaymentMethodCard({
    super.key,
    required this.method,
    required this.isSaving,
    required this.onChanged,
    required this.enabledLabel,
    required this.disabledLabel,
    required this.comingSoonLabel,
    required this.credentialsRequiredLabel,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final canToggle = method.supportedNow && !isSaving;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: Icon(
                  _icon(),
                  color: _iconColor(primary),
                  size: 26,
                ),
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
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      method.helperText,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
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
                    strokeWidth: 2.5,
                    color: primary,
                  ),
                )
              else
                Switch(
                  value: method.projectEnabled,
                  activeColor: primary,
                  onChanged: canToggle ? onChanged : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PaymentMethodStatusChip(
                enabled: method.projectEnabled,
                enabledText: enabledLabel,
                disabledText: disabledLabel,
              ),
              if (!method.supportedNow)
                _InfoPill(
                  text: comingSoonLabel,
                  icon: Icons.schedule_rounded,
                ),
              if (method.requiresCredentials)
                _InfoPill(
                  text: credentialsRequiredLabel,
                  icon: Icons.key_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _displayTitle() {
    final code = method.code.toUpperCase();
    if (code == 'MPGS') return 'Credit / Debit Card';
    return method.displayName;
  }

  IconData _icon() {
    switch (method.code.toUpperCase()) {
      case 'CASH':
        return Icons.payments_outlined;
      case 'STRIPE':
        return Icons.credit_card_rounded;
      case 'PAYPAL':
        return Icons.account_balance_wallet_outlined;
      case 'MPGS':
        return Icons.payment_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _iconColor(Color primary) {
    switch (method.code.toUpperCase()) {
      case 'CASH':
        return const Color(0xFF16A34A);
      case 'STRIPE':
      case 'MPGS':
        return primary;
      case 'PAYPAL':
        return const Color(0xFF2563EB);
      default:
        return primary;
    }
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoPill({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

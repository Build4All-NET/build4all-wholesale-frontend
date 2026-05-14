import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/tax_rule_entity.dart';

class TaxRuleCard extends StatelessWidget {
  final TaxRuleEntity rule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaxRuleCard({
    super.key,
    required this.rule,
    this.onEdit,
    this.onDelete,
  });

  String _statusLabel(BuildContext context) {
    final normalizedStatus = rule.status?.trim().toUpperCase();

    if (normalizedStatus == 'ACTIVE') {
      return context.l10n.activeStatus;
    }

    if (normalizedStatus == 'INACTIVE') {
      return context.l10n.inactiveStatus;
    }

    return rule.active ? context.l10n.activeStatus : context.l10n.inactiveStatus;
  }

  bool _isActiveStatus() {
    final normalizedStatus = rule.status?.trim().toUpperCase();

    if (normalizedStatus == 'ACTIVE') return true;
    if (normalizedStatus == 'INACTIVE') return false;

    return rule.active;
  }

  String _scopeLabel(BuildContext context) {
    final regionName = rule.regionName?.trim();

    if (regionName != null && regionName.isNotEmpty) {
      return context.l10n.regionRuleLabel;
    }

    return context.l10n.countryRuleLabel;
  }

  String _shippingTaxLabel(BuildContext context) {
    return rule.appliesToShipping
        ? context.l10n.appliesToShippingLabel
        : context.l10n.itemsOnlyTaxLabel;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.percent_outlined,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.ruleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${rule.rateLabel} • ${_scopeLabel(context)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(
                status: _statusLabel(context),
                active: _isActiveStatus(),
              ),
            ],
          ),
          if (rule.notes != null && rule.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              rule.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TextChip(text: rule.locationLabel),
              _TextChip(text: _shippingTaxLabel(context)),
              _TextChip(text: context.l10n.orderLevelTaxLabel),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppThemeTokens.border),
          const SizedBox(height: 14),
          Row(
            children: [
              if (onEdit != null) ...[
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: context.l10n.editButton,
                    onPressed: onEdit!,
                    borderColor: primary.withValues(alpha: 0.35),
                    textColor: primary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (onDelete != null)
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: context.l10n.delete,
                    onPressed: onDelete!,
                    borderColor: Colors.red.withValues(alpha: 0.45),
                    textColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool active;

  const _StatusPill({
    required this.status,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F7EF) : const Color(0xFFF4E8EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: active ? const Color(0xFF15803D) : const Color(0xFF9B4D6D),
        ),
      ),
    );
  }
}

class _TextChip extends StatelessWidget {
  final String text;

  const _TextChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: const Size(0, 46),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

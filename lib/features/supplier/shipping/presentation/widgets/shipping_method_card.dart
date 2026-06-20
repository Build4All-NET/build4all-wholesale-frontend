import 'package:flutter/material.dart';

import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/shipping_method_entity.dart';

class ShippingMethodCard extends StatelessWidget {
  final ShippingMethodEntity method;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ShippingMethodCard({
    super.key,
    required this.method,
    this.onEdit,
    this.onDelete,
  });

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
                  method.isPickup
                      ? Icons.storefront_outlined
                      : Icons.local_shipping_outlined,
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
                      method.name,
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
                      '${_localizedOptionLabel(context, method.methodTypeLabel)} • ${_shippingCostLabel(context, method)}',
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
              _StatusPill(status: _localizedStatusLabel(context, method.statusLabel)),
            ],
          ),
          if (method.notes != null && method.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              method.notes!,
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
              _TextChip(text: _localizedLocationLabel(context, method.locationLabel)),
              _TextChip(text: _localizedEstimatedTime(context, method.estimatedDeliveryTime)),
              _TextChip(text: _minimumOrderLabel(context, method)),
              _TextChip(text: _freeShippingLabel(context, method)),
              _TextChip(text: context.l10n.supplierBranchesValue(_localizedBranchScopeLabel(context, method.branchScopeLabel))),
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
                    label: context.l10n.deleteButton,
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

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final active = status.toLowerCase() == 'active';

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

  _TextChip({required this.text});

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

String _localizedOptionLabel(BuildContext context, String label) {
  switch (label) {
    case 'Pickup from Branch':
      return context.l10n.supplierPickupFromBranch;
    case 'Express Delivery':
      return context.l10n.supplierExpressDelivery;
    case 'Standard Delivery':
      return context.l10n.supplierStandardDelivery;
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
    default:
      return label;
  }
}

String _shippingCostLabel(BuildContext context, ShippingMethodEntity method) {
  if (method.isPickup) return context.l10n.supplierFreePickup;
  return CurrencyFormatter.formatCompact(context, method.cost);
}

String _minimumOrderLabel(BuildContext context, ShippingMethodEntity method) {
  final value = method.minimumOrderAmount;
  if (value == null) return context.l10n.supplierNoMinimum;
  return context.l10n.supplierMinimumValue(
    CurrencyFormatter.formatCompact(context, value),
  );
}

String _freeShippingLabel(BuildContext context, ShippingMethodEntity method) {
  if (method.isPickup) return context.l10n.supplierPickupOnly;

  final value = method.freeShippingThreshold;
  if (value == null) return context.l10n.supplierNoFreeShipping;

  return context.l10n.supplierFreeAboveValue(
    CurrencyFormatter.formatCompact(context, value),
  );
}

String _localizedEstimatedTime(BuildContext context, String label) {
  if (label == 'Pickup from branch') return context.l10n.supplierPickupFromBranch;
  return label;
}

String _localizedLocationLabel(BuildContext context, String label) {
  if (label == 'No location selected') return context.l10n.supplierNoLocationSelected;
  return label;
}

String _localizedBranchScopeLabel(BuildContext context, String label) {
  if (label == 'All Branches') return context.l10n.supplierAllBranches;
  if (label == 'No branches selected') return context.l10n.supplierNoBranchesSelected;
  return label;
}

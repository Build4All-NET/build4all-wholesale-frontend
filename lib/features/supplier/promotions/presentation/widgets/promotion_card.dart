import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PromotionCard({
    super.key,
    required this.promotion,
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
              _PromotionBadge(
                primary: primary,
                discountLabel: promotion.discountLabel,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
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
                      '${_localizedOptionLabel(context, promotion.discountTypeLabel)} • ${promotion.discountLabel}',
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
                status: _localizedStatusLabel(context, promotion.statusLabel),
                rawStatus: promotion.statusLabel,
              ),
            ],
          ),
          if (promotion.description != null &&
              promotion.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              promotion.description!,
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
              _TextChip(text: _localizedTargetLabel(context, promotion)),
              _TextChip(text: _localizedValidityLabel(context, promotion)),
              _TextChip(text: _localizedMinOrderLabel(context, promotion)),
              _TextChip(text: _localizedMaxDiscountLabel(context, promotion)),
              _TextChip(text: context.l10n.supplierBranchesValue(_localizedBranchScopeLabel(context, promotion.branchScopeLabel))),
              _TextChip(
                text: context.l10n.supplierValidNowValue(promotion.currentlyValid ? context.l10n.yesLabel : context.l10n.noLabel),
              ),
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

class _PromotionBadge extends StatelessWidget {
  final Color primary;
  final String discountLabel;

  const _PromotionBadge({
    required this.primary,
    required this.discountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: primary.withValues(alpha: 0.12),
      child: Icon(
        Icons.local_offer_outlined,
        color: primary,
        size: 28,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final String rawStatus;

  const _StatusPill({
    required this.status,
    required this.rawStatus,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = rawStatus.toLowerCase();

    final active = normalized == 'active';
    final scheduled = normalized == 'scheduled';
    final expired = normalized == 'expired';

    final background = active
        ? const Color(0xFFE8F7EF)
        : scheduled
            ? const Color(0xFFEFF6FF)
            : expired
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFF4E8EE);

    final textColor = active
        ? const Color(0xFF15803D)
        : scheduled
            ? const Color(0xFF1D4ED8)
            : expired
                ? const Color(0xFFC2410C)
                : const Color(0xFF9B4D6D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: textColor,
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


String _localizedTargetLabel(BuildContext context, PromotionEntity promotion) {
  if (promotion.targetType == PromotionTargetType.allProducts) {
    return context.l10n.supplierAllProducts;
  }

  final safeName = promotion.targetName?.trim();
  final targetTypeLabel = _localizedOptionLabel(context, promotion.targetType.label);

  if (safeName != null && safeName.isNotEmpty) {
    return '$targetTypeLabel: $safeName';
  }

  return targetTypeLabel;
}

String _localizedValidityLabel(BuildContext context, PromotionEntity promotion) {
  final start = promotion.startDate;
  final end = promotion.endDate;

  if (start == null && end == null) {
    return '—';
  }

  if (start != null && end != null) {
    return '${_formatPromotionDate(context, start)} → ${_formatPromotionDate(context, end)}';
  }

  return _formatPromotionDate(context, start ?? end!);
}

String _localizedMinOrderLabel(BuildContext context, PromotionEntity promotion) {
  final minOrderAmount = promotion.minOrderAmount;

  if (minOrderAmount == null) {
    return context.l10n.supplierNoMinimum;
  }

  return context.l10n.supplierMinimumValue(_formatCurrencyAmount(minOrderAmount));
}

String _localizedMaxDiscountLabel(BuildContext context, PromotionEntity promotion) {
  if (!promotion.isPercent) {
    return context.l10n.noneLabel;
  }

  final maxDiscountAmount = promotion.maxDiscountAmount;

  if (maxDiscountAmount == null) {
    return context.l10n.supplierUnlimited;
  }

  return '${context.l10n.supplierMaxDiscount}: ${_formatCurrencyAmount(maxDiscountAmount)}';
}

String _formatPromotionDate(BuildContext context, DateTime value) {
  final localeTag = Localizations.localeOf(context).toLanguageTag();

  return DateFormat('yyyy-MM-dd h:mm a', localeTag).format(value);
}

String _formatCurrencyAmount(double value) {
  final formatted = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  return '\$$formatted';
}

String _localizedOptionLabel(BuildContext context, String label) {
  switch (label) {
    case 'Pickup from Branch':
      return context.l10n.supplierPickupFromBranch;
    case 'Express Delivery':
      return context.l10n.supplierExpressDelivery;
    case 'Standard Delivery':
      return context.l10n.supplierStandardDelivery;
    case 'All Branches':
      return context.l10n.supplierAllBranches;
    case 'Selected Branches':
      return context.l10n.supplierSelectedBranches;
    case 'Percent':
      return context.l10n.supplierPercent;
    case 'Fixed Amount':
      return context.l10n.supplierFixedAmount;
    case 'Fixed':
      return context.l10n.supplierFixed;
    case 'Free Shipping':
      return context.l10n.supplierFreeShipping;
    case 'All Products':
      return context.l10n.supplierAllProducts;
    case 'Product':
      return context.l10n.productLabel;
    case 'Category':
      return context.l10n.categoryLabel;
    case 'SubCategory':
      return context.l10n.subCategoryLabel;
    case 'Subcategory':
      return context.l10n.subcategoryLabel;
    case 'None':
      return context.l10n.noneLabel;
    case 'URL':
      return context.l10n.urlLabel;
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
    case 'usage limit reached':
    case 'usage_limit_reached':
      return context.l10n.supplierUsageLimitReached;
    default:
      return label;
  }
}

String _localizedBranchScopeLabel(BuildContext context, String label) {
  if (label == 'All Branches') return context.l10n.supplierAllBranches;
  if (label == 'No branches selected') return context.l10n.supplierNoBranchesSelected;
  return label;
}

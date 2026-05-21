import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/coupon_entity.dart';

class CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  String _usageText() {
    if (coupon.maxUses == null) {
      return '${coupon.usedCount} / ∞';
    }

    return '${coupon.usedCount} / ${coupon.maxUses}';
  }

  String _remainingText(BuildContext context) {
    if (coupon.remainingUses == null) return context.l10n.supplierUnlimited;
    return coupon.remainingUses.toString();
  }

  String _validityText(BuildContext context) {
    if (coupon.startsAt == null && coupon.expiresAt == null) {
      return context.l10n.supplierAlwaysActive;
    }

    return '${_formatDate(coupon.startsAt)} → ${_formatDate(coupon.expiresAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CouponCodeBox(
                code: coupon.code,
                primary: primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_localizedOptionLabel(context, coupon.discountType.label)} • ${coupon.discountLabel}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(coupon: coupon),
            ],
          ),
          if (coupon.description != null &&
              coupon.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              coupon.description!,
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
          const SizedBox(height: 12),
          Text(
            _validityText(context),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: context.l10n.supplierUsed, value: _usageText()),
              _InfoChip(label: context.l10n.supplierRemaining, value: _remainingText(context)),
              _InfoChip(
                label: context.l10n.supplierMinOrder,
                value: coupon.minOrderAmount == null
                    ? '—'
                    : coupon.minOrderAmount!.toStringAsFixed(2),
              ),
              _InfoChip(
                label: context.l10n.supplierMaxDiscount,
                value: coupon.maxDiscountAmount == null
                    ? '—'
                    : coupon.maxDiscountAmount!.toStringAsFixed(2),
              ),
              _InfoChip(
                label: context.l10n.branchesLabel,
                value: coupon.branchApplicabilityLabel,
              ),
              _InfoChip(
                label: context.l10n.supplierValidNow,
                value: coupon.currentlyValid ? context.l10n.yesLabel : context.l10n.noLabel,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppThemeTokens.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: Text(context.l10n.editButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withOpacity(0.35)),
                      backgroundColor: primary.withOpacity(0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: Text(context.l10n.deleteButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CouponCodeBox extends StatelessWidget {
  final String code;
  final Color primary;

  const _CouponCodeBox({
    required this.code,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: primary),
      child: Container(
        width: 82,
        height: 52,
        alignment: Alignment.center,
        child: Text(
          code.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CouponEntity coupon;

  const _StatusBadge({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final Color backgroundColor;
    final Color textColor;

    switch (coupon.status) {
      case 'INACTIVE':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'SCHEDULED':
        backgroundColor = primary.withOpacity(0.12);
        textColor = primary;
        break;
      case 'EXPIRED':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'USAGE_LIMIT_REACHED':
        backgroundColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        break;
      case 'ACTIVE':
      default:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _localizedStatusLabel(context, coupon.statusLabel),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppThemeTokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    const dashWidth = 7.0;
    const dashGap = 5.0;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(13),
    );

    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );

        canvas.drawPath(segment, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
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

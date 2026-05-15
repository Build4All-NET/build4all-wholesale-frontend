import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/banner_entity.dart';

class BannerCard extends StatelessWidget {
  final BannerEntity banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _copyBanner(BuildContext context) async {
    final textToCopy = banner.imageUrl.trim().isNotEmpty
        ? banner.imageUrl.trim()
        : banner.title.trim();

    await Clipboard.setData(
      ClipboardData(text: textToCopy),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.supplierBannerCopiedSuccessfully),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final statusColor = _statusColor();
    final visibleText = banner.currentlyVisible ? context.l10n.yesLabel : context.l10n.noLabel;

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
          _BannerImage(
            imageUrl: banner.imageUrl,
            primary: primary,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(
                text: banner.statusLabel,
                color: statusColor,
              ),
            ],
          ),
          if (banner.subtitle != null &&
              banner.subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              banner.subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            banner.validityLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                text: context.l10n.supplierTargetValue(_localizedTargetLabel(context, banner.targetLabelText)),
              ),
              _InfoChip(
                text: context.l10n.supplierOrderValue(banner.sortOrder.toString()),
              ),
              _InfoChip(
                text: context.l10n.supplierVisibleNowValue(visibleText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppThemeTokens.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_outlined,
                  label: context.l10n.copyButton,
                  onPressed: () => _copyBanner(context),
                  color: AppThemeTokens.textSecondary,
                  borderColor: AppThemeTokens.border,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: context.l10n.editButton,
                  onPressed: onEdit,
                  color: primary,
                  borderColor: primary.withOpacity(0.35),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline,
                  label: context.l10n.deleteButton,
                  onPressed: onDelete,
                  color: Colors.red,
                  borderColor: Colors.red.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor() {
    switch (banner.status) {
      case 'INACTIVE':
        return Colors.grey;
      case 'SCHEDULED':
        return const Color(0xFF9F4F73);
      case 'EXPIRED':
        return Colors.red;
      case 'ACTIVE':
      default:
        return Colors.green;
    }
  }
}

class _BannerImage extends StatelessWidget {
  final String imageUrl;
  final Color primary;

  const _BannerImage({
    required this.imageUrl,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: cleanUrl.isEmpty
          ? Icon(
              Icons.image_outlined,
              color: primary,
              size: 42,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                cleanUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image_outlined,
                    color: primary,
                    size: 42,
                  );
                },
              ),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  _InfoChip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
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
  final Color color;
  final Color borderColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: color,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
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

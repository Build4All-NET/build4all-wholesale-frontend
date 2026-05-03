import 'package:flutter/material.dart';

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

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  String _validityText() {
    if (banner.startsAt == null && banner.endsAt == null) {
      return 'Always visible';
    }

    return '${_formatDate(banner.startsAt)} → ${_formatDate(banner.endsAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
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
          _BannerPreview(
            banner: banner,
            primary: primary,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    _StatusBadge(banner: banner),
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
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Text(
                  _validityText(),
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
                    _InfoChip(
                      label: 'Order',
                      value: banner.displayOrder.toString(),
                    ),
                    _InfoChip(
                      label: 'Target',
                      value: banner.targetLabel,
                    ),
                    _InfoChip(
                      label: 'Visible now',
                      value: banner.currentlyVisible ? 'Yes' : 'No',
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
                          label: const Text('Edit'),
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
                          label: const Text('Delete'),
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
          ),
        ],
      ),
    );
  }
}

class _BannerPreview extends StatelessWidget {
  final BannerEntity banner;
  final Color primary;

  const _BannerPreview({
    required this.banner,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = banner.imageUrl.trim().isNotEmpty;

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeTokens.radiusLarge),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeTokens.radiusLarge),
        ),
        child: hasImage
            ? Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _BannerPlaceholder(
                    primary: primary,
                    title: banner.title,
                  );
                },
              )
            : _BannerPlaceholder(
                primary: primary,
                title: banner.title,
              ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  final Color primary;
  final String title;

  const _BannerPlaceholder({
    required this.primary,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary.withOpacity(0.12),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primary.withOpacity(0.14),
            child: Icon(
              Icons.image_outlined,
              color: primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BannerEntity banner;

  const _StatusBadge({required this.banner});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final Color backgroundColor;
    final Color textColor;

    switch (banner.status) {
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
        banner.statusLabel,
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

  const _InfoChip({
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
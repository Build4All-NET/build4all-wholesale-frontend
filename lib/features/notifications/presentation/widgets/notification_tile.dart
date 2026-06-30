import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/notification_entity.dart';

/// A single notification row. Unread items get a subtle tint, a bold title and
/// an unread dot; the icon is chosen from the notification type code.
class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;
    final localeCode = Localizations.localeOf(context).languageCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? AppThemeTokens.primary.withValues(alpha: 0.06)
              : AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppThemeTokens.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(notification.typeCode),
                color: AppThemeTokens.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.title != null &&
                      notification.title!.isNotEmpty)
                    Text(
                      notification.title!,
                      style: TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight:
                            unread ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  if (notification.body != null &&
                      notification.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(notification.createdAt!, localeCode),
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppThemeTokens.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String typeCode) {
    if (typeCode.startsWith('RFQ')) return Icons.request_quote_outlined;
    if (typeCode.contains('CANCELLED')) return Icons.cancel_outlined;
    if (typeCode.contains('DELIVERED')) return Icons.check_circle_outline;
    if (typeCode.contains('SHIPPED')) return Icons.local_shipping_outlined;
    if (typeCode.contains('PREPARING')) return Icons.inventory_2_outlined;
    if (typeCode.contains('ACCEPTED')) return Icons.thumb_up_alt_outlined;
    if (typeCode.startsWith('ORDER')) return Icons.receipt_long_outlined;
    return Icons.notifications_none_rounded;
  }

  String _formatDate(DateTime dateUtc, String localeCode) {
    final date = dateUtc.toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    try {
      return DateFormat.yMMMd(localeCode).format(date);
    } catch (_) {
      return DateFormat.yMMMd().format(date);
    }
  }
}

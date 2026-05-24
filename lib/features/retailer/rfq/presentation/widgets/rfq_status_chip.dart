import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';

class RfqStatusChip extends StatelessWidget {
  final String status;

  const RfqStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = status.toUpperCase();

    final config = switch (normalized) {
      'OPEN' => _ChipConfig(
        label: l10n.rfqOpen,
        icon: Icons.radio_button_checked_rounded,
        color: const Color(0xFF2563EB),
        background: const Color(0xFFEFF6FF),
      ),
      'QUOTED' => _ChipConfig(
        label: l10n.rfqQuoted,
        icon: Icons.mark_chat_unread_outlined,
        color: const Color(0xFF7C3AED),
        background: const Color(0xFFF5F3FF),
      ),
      'ACCEPTED' => _ChipConfig(
        label: l10n.rfqAccepted,
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF16A34A),
        background: const Color(0xFFDCFCE7),
      ),
      'CLOSED' => _ChipConfig(
        label: l10n.rfqClosed,
        icon: Icons.lock_outline_rounded,
        color: const Color(0xFF475569),
        background: const Color(0xFFF1F5F9),
      ),
      'CANCELLED' => _ChipConfig(
        label: l10n.rfqCancelled,
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
        background: const Color(0xFFFEE2E2),
      ),
      'EXPIRED' => _ChipConfig(
        label: l10n.rfqExpired,
        icon: Icons.hourglass_disabled_outlined,
        color: const Color(0xFFB45309),
        background: const Color(0xFFFEF3C7),
      ),
      _ => _ChipConfig(
        label: normalized,
        icon: Icons.info_outline_rounded,
        color: AppThemeTokens.textSecondary,
        background: AppThemeTokens.background,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 15, color: config.color),
          const SizedBox(width: 5),
          Text(
            config.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _ChipConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

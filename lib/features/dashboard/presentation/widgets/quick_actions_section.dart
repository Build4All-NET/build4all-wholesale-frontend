import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class QuickActionsSection extends StatelessWidget {
  final List<QuickActionModel> actions;

  const QuickActionsSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .take(4)
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QuickActionTile(action: action),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickActionModel action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(
      action.colorHex,
      Theme.of(context).colorScheme.primary,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openAction(context, action),
      child: Container(
        height: 94,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppThemeTokens.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconFromName(action.icon), color: color, size: 26),
            const SizedBox(height: 9),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAction(BuildContext context, QuickActionModel action) {
    final label = action.label.toLowerCase();

    if (label.contains('ai')) {
      context.push('/retailer-ai-assistant');
    } else if (label.contains('chat')) {
      context.push('/retailer-live-chat');
    } else if (label.contains('loyalty')) {
      context.push('/retailer-loyalty');
    } else if (label.contains('ranking')) {
      context.push('/retailer-top-ranking');
    } else {
      context.push('/retailer-promotions');
    }
  }

  IconData _iconFromName(String value) {
    switch (value) {
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'star':
        return Icons.star_border_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _parseColor(String hex, Color fallback) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value == null ? fallback : Color(value);
  }
}

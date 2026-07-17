import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class EmptyCatalogMessage extends StatelessWidget {
  final String message;
  final IconData icon;

  EmptyCatalogMessage({
    super.key,
    required this.message,
    this.icon = Icons.category_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Icon(icon, color: primary, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


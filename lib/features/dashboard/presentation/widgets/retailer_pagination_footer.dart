import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';

class RetailerPaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNext;
  final bool showEndMessage;

  const RetailerPaginationFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasNext,
    this.showEndMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Loading more...',
              style: TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasNext && showEndMessage) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'No more products',
            style: TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

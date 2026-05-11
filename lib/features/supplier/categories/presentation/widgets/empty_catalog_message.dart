import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class EmptyCatalogMessage extends StatelessWidget {
  final String message;

  const EmptyCatalogMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }
}


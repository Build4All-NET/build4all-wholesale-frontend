import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class EmptyCatalogMessage extends StatelessWidget {
  final String message;

  EmptyCatalogMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textSecondary,
        ),
      ),
    );
  }
}


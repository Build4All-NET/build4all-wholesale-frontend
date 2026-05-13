import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class CatalogSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  CatalogSearchBox({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            Icons.search,
            color: AppThemeTokens.textSecondary,
          ),
          filled: true,
          fillColor: AppThemeTokens.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusSmall),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class CatalogSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const CatalogSearchBox({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(
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

import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

class AppThemeBuilder {
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppThemeTokens.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppThemeTokens.primary,
        primary: AppThemeTokens.primary,
        error: AppThemeTokens.error,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppThemeTokens.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppThemeTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppThemeTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppThemeTokens.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeTokens.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: const BorderSide(
            color: AppThemeTokens.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: const BorderSide(
            color: AppThemeTokens.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: const BorderSide(
            color: AppThemeTokens.error,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

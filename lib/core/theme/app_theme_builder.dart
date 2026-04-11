import 'package:flutter/material.dart';
import 'app_theme_config.dart';
import 'app_theme_tokens.dart';

class AppThemeBuilder {
  static ThemeData buildTheme(AppThemeConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.seedColor,
      brightness: config.brightness,
    );

    final isDark = config.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: config.brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : AppThemeTokens.background,
      colorScheme: colorScheme,
      primaryColor: config.seedColor,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : AppThemeTokens.background,
        foregroundColor:
            isDark ? Colors.white : AppThemeTokens.textPrimary,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppThemeTokens.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppThemeTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : AppThemeTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : AppThemeTokens.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : AppThemeTokens.inputFill,
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
          borderSide: BorderSide(
            color: config.seedColor,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          ),
        ),
      ),
    );
  }
}

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
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0F172A)
          : AppThemeTokens.background,
      colorScheme: colorScheme,
      primaryColor: config.seedColor,

      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : AppThemeTokens.background,
        foregroundColor: isDark ? Colors.white : AppThemeTokens.textPrimary,
        elevation: 0,
        centerTitle: true,
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
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey.shade500,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade700,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: config.seedColor,
        suffixIconColor: config.seedColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: BorderSide(color: config.seedColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: const BorderSide(color: AppThemeTokens.error, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          borderSide: const BorderSide(color: AppThemeTokens.error, width: 2.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.seedColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          side: BorderSide(
            color: isDark ? Colors.white12 : AppThemeTokens.border,
          ),
        ),
      ),
    );
  }
}

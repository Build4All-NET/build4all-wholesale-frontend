import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/app_config.dart';
import '../storage/theme_storage.dart';
import 'app_theme_config.dart';
import 'remote_theme_dto.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeStorage themeStorage;

  ThemeCubit(this.themeStorage)
    : super(ThemeState(config: AppThemeConfig.fallback()));

  Future<void> loadSavedTheme() async {
    final envConfig = _themeFromEnv();

    if (envConfig != null) {
      emit(ThemeState(config: envConfig));
      debugPrint('Theme applied from env THEME_JSON_B64 / THEME_JSON');
      return;
    }

    final savedColor = await themeStorage.getSeedColor();
    final savedBrightness = await themeStorage.getBrightness();

    emit(
      ThemeState(
        config: AppThemeConfig.fallback().copyWith(
          seedColor: savedColor ?? const Color(0xFF16A34A),
          brightness: savedBrightness ?? Brightness.light,
        ),
      ),
    );
  }

  AppThemeConfig? _themeFromEnv() {
    try {
      if (AppConfig.themeJsonB64.trim().isNotEmpty) {
        final remote = RemoteThemeDto.fromBase64Json(AppConfig.themeJsonB64);
        return AppThemeConfig.fromRemote(remote);
      }

      if (AppConfig.themeJson.trim().isNotEmpty) {
        final remote = RemoteThemeDto.fromJsonString(AppConfig.themeJson);
        return AppThemeConfig.fromRemote(remote);
      }
    } catch (e) {
      debugPrint('Env theme parse failed: $e');
    }

    return null;
  }


  Future<void> applyRemoteThemeJson(String themeJson) async {
    try {
      if (themeJson.trim().isEmpty) return;
      final remote = RemoteThemeDto.fromJsonString(themeJson);
      emit(ThemeState(config: AppThemeConfig.fromRemote(remote)));
    } catch (e) {
      debugPrint('Runtime theme json parse failed: $e');
    }
  }

  Future<void> applyRemoteThemeB64(String themeJsonB64) async {
    try {
      if (themeJsonB64.trim().isEmpty) return;
      final remote = RemoteThemeDto.fromBase64Json(themeJsonB64);
      emit(ThemeState(config: AppThemeConfig.fromRemote(remote)));
    } catch (e) {
      debugPrint('Runtime theme b64 parse failed: $e');
    }
  }

  Future<void> updateSeedColor(Color color) async {
    final updatedConfig = state.config.copyWith(seedColor: color);

    await themeStorage.saveTheme(
      seedColor: updatedConfig.seedColor,
      brightness: updatedConfig.brightness,
    );

    emit(state.copyWith(config: updatedConfig));
  }

  Future<void> updateBrightness(Brightness brightness) async {
    final updatedConfig = state.config.copyWith(brightness: brightness);

    await themeStorage.saveTheme(
      seedColor: updatedConfig.seedColor,
      brightness: updatedConfig.brightness,
    );

    emit(state.copyWith(config: updatedConfig));
  }

  Future<void> applyThemeFromHex(String hexColor) async {
    final color = _hexToColor(hexColor);
    await updateSeedColor(color);
  }

  Color _hexToColor(String hex) {
    var cleaned = hex.replaceAll('#', '').trim();

    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }

    return Color(int.parse(cleaned, radix: 16));
  }
}

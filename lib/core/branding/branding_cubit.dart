import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/app_config.dart';
import '../storage/branding_storage.dart';
import 'branding_state.dart';

class BrandingCubit extends Cubit<BrandingState> {
  final BrandingStorage storage;

  BrandingCubit(this.storage)
    : super(
        const BrandingState(
          appName: AppConfig.appName,
          logoUrl: AppConfig.appLogoUrl,
          logoAsset: AppConfig.appLogoAsset,
          isLoaded: false,
        ),
      );

  Future<void> loadInitialBranding() async {
    final savedAppName = await storage.getAppName();
    final savedLogoUrl = await storage.getLogoUrl();

    final appName = _firstNotEmpty([
      savedAppName,
      AppConfig.appName,
    ], AppConfig.appName);

    final logoUrl = _firstNotEmpty([
      savedLogoUrl,
      AppConfig.appLogoUrl,
    ], '');

    emit(
      state.copyWith(
        appName: appName,
        logoUrl: logoUrl,
        logoAsset: AppConfig.appLogoAsset,
        isLoaded: true,
      ),
    );
  }

  Future<void> applyBranding({
    String? appName,
    String? logoUrl,
    String? logoAsset,
    bool persist = true,
  }) async {
    final resolvedAppName = _firstNotEmpty([
      appName,
      state.appName,
      AppConfig.appName,
    ], AppConfig.appName);

    final resolvedLogoUrl = _firstNotEmpty([
      logoUrl,
      state.logoUrl,
      AppConfig.appLogoUrl,
    ], '');

    final resolvedLogoAsset = _firstNotEmpty([
      logoAsset,
      state.logoAsset,
      AppConfig.appLogoAsset,
    ], AppConfig.appLogoAsset);

    if (persist) {
      await storage.saveBranding(
        appName: resolvedAppName,
        logoUrl: resolvedLogoUrl,
      );
    }

    emit(
      state.copyWith(
        appName: resolvedAppName,
        logoUrl: resolvedLogoUrl,
        logoAsset: resolvedLogoAsset,
        isLoaded: true,
      ),
    );
  }

  static String _firstNotEmpty(List<String?> values, String fallback) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }
}

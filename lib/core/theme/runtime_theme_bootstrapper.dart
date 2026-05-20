import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../branding/branding_cubit.dart';
import '../config/app_config.dart';
import 'runtime_theme_service.dart';
import 'theme_cubit.dart';

class RuntimeThemeBootstrapper extends StatefulWidget {
  final Widget child;

  const RuntimeThemeBootstrapper({super.key, required this.child});

  @override
  State<RuntimeThemeBootstrapper> createState() =>
      _RuntimeThemeBootstrapperState();
}

class _RuntimeThemeBootstrapperState extends State<RuntimeThemeBootstrapper> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    _loadRuntimeConfig();
  }

  Future<void> _loadRuntimeConfig() async {
    final brandingCubit = context.read<BrandingCubit>();

    await brandingCubit.applyBranding(
      appName: AppConfig.appName,
      logoUrl: AppConfig.appLogoUrl,
      logoAsset: AppConfig.appLogoAsset,
      persist: false,
    );

    final service = context.read<RuntimeThemeService>();
    final config = await service.fetchRuntimeConfig();

    if (!mounted || config == null) return;

    await brandingCubit.applyBranding(
      appName: config.appName ?? AppConfig.appName,
      logoUrl: config.logoUrl ?? AppConfig.appLogoUrl,
      logoAsset: AppConfig.appLogoAsset,
    );

    final themeCubit = context.read<ThemeCubit>();

    // Runtime config from Build4All is the source of truth for the selected
    // application theme. The env theme is only a fallback while the request is
    // loading or if the runtime endpoint is unavailable.
    final runtimeB64 = config.themeJsonB64?.trim() ?? '';
    if (runtimeB64.isNotEmpty) {
      await themeCubit.applyRemoteThemeB64(runtimeB64);
      return;
    }

    final runtimeJson = config.themeJson?.trim() ?? '';
    if (runtimeJson.isNotEmpty) {
      await themeCubit.applyRemoteThemeJson(runtimeJson);
      return;
    }

    if (config.primaryColorHex != null &&
        config.primaryColorHex!.trim().isNotEmpty) {
      await themeCubit.applyThemeFromHex(config.primaryColorHex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

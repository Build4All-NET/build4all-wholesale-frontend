import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/branding_storage.dart';
import 'runtime_theme_service.dart';
import 'theme_cubit.dart';

class RuntimeThemeBootstrapper extends StatefulWidget {
  final Widget child;

  const RuntimeThemeBootstrapper({
    super.key,
    required this.child,
  });

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
    final service = context.read<RuntimeThemeService>();
    final themeCubit = context.read<ThemeCubit>();
    final brandingStorage = BrandingStorage();

    final config = await service.fetchRuntimeConfig();

    if (!mounted || config == null) return;

    if (config.primaryColorHex != null &&
        config.primaryColorHex!.trim().isNotEmpty) {
      await themeCubit.applyThemeFromHex(config.primaryColorHex!);
    }

    await brandingStorage.saveBranding(
      appName: config.appName ?? 'B2B Wholesale App',
      logoUrl: config.logoUrl ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
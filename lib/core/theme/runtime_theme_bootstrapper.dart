import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    _loadRuntimeTheme();
  }

  Future<void> _loadRuntimeTheme() async {
    final service = context.read<RuntimeThemeService>();
    final themeCubit = context.read<ThemeCubit>();

    final primaryHex = await service.fetchPrimaryColorHex();

    if (!mounted) return;

    if (primaryHex != null && primaryHex.isNotEmpty) {
      await themeCubit.applyThemeFromHex(primaryHex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


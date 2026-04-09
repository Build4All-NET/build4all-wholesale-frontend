import 'package:flutter/material.dart';
import '../core/theme/app_theme_builder.dart';
import 'app_router.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'B2B Wholesale App',
      theme: AppThemeBuilder.buildLightTheme(),
      routerConfig: AppRouter.router,
    );
  }
}



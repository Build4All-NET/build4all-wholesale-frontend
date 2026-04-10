import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await sl<ThemeCubit>().loadSavedTheme();
  await sl<LocaleCubit>().loadSavedLocale();
  runApp(const App());
}

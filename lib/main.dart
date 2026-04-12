import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'core/config/app_config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await sl<ThemeCubit>().loadSavedTheme();
  await sl<LocaleCubit>().loadSavedLocale();
  debugPrint('APP_NAME: ${AppConfig.appName}');
  debugPrint('API_BASE_URL: ${AppConfig.baseUrl}');
  debugPrint('APP_TYPE: ${AppConfig.appType}');
  debugPrint('OWNER_PROJECT_LINK_ID: ${AppConfig.ownerProjectLinkId}');
  debugPrint('PROJECT_ID: ${AppConfig.projectId}');
  debugPrint('CURRENCY_ID: ${AppConfig.currencyId}');
  debugPrint('DEFAULT_LANGUAGE: ${AppConfig.defaultLanguage}');

  runApp(const App());
}

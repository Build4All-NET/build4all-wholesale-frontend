import 'package:flutter/widgets.dart';
import 'package:build4all_wholesale_frontend/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/locale_storage.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final LocaleStorage localeStorage;

  LocaleCubit(this.localeStorage) : super(const LocaleState(Locale('en')));

  Future<void> loadSavedLocale() async {
    final savedCode = await localeStorage.getLocale();
    if (savedCode != null && savedCode.isNotEmpty) {
      emit(LocaleState(Locale(savedCode)));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    await localeStorage.saveLocale(languageCode);
    emit(LocaleState(Locale(languageCode)));
  }
}

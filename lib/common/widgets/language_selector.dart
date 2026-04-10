import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/locale_cubit.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: context.l10n.language,
      onSelected: (value) {
        localeCubit.changeLocale(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Text(context.l10n.english),
        ),
        PopupMenuItem(
          value: 'fr',
          child: Text(context.l10n.french),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Text(context.l10n.arabic),
        ),
      ],
    );
  }
}
